@tool
extends EditorScript
# tools/import_quiz.gd — Tool editor untuk mengimpor seluruh soal dari docs/quiz_bank.md menjadi .tres

func _run() -> void:
	print("[import_quiz] Memulai import soal dari docs/quiz_bank.md...")
	var imported_count := import_all_questions()
	print("[import_quiz] Selesai! Berhasil memuat dan memperbarui %d soal .tres." % imported_count)

static func import_all_questions(md_path: String = "res://docs/quiz_bank.md", out_dir: String = "res://resources/questions/") -> int:
	if not FileAccess.file_exists(md_path):
		# Coba fallback path jika diakses dari folder proyek berbeda
		if FileAccess.file_exists("res://../aset/docs/quiz_bank.md"):
			md_path = "res://../aset/docs/quiz_bank.md"
		else:
			push_error("[import_quiz] File %s tidak ditemukan!" % md_path)
			return 0

	var file := FileAccess.open(md_path, FileAccess.READ)
	if not file:
		push_error("[import_quiz] Gagal membaca file %s" % md_path)
		return 0

	var content := file.get_as_text()
	file.close()

	if not DirAccess.dir_exists_absolute(out_dir):
		DirAccess.make_dir_recursive_absolute(out_dir)

	var sections := content.split("### Soal ")
	var count := 0

	var regex_id := RegEx.create_from_string("\\*\\*ID:\\*\\*\\s*`?([A-Za-z0-9_]+)`?")
	var regex_layer := RegEx.create_from_string("\\*\\*Layer:\\*\\*\\s*`?([A-Za-z0-9_]+)`?")
	var regex_type := RegEx.create_from_string("\\*\\*Tipe:\\*\\*\\s*`?([A-Za-z0-9_]+)`?")
	var regex_q := RegEx.create_from_string("\\*\\*Pertanyaan:\\*\\*\\s*(.+)")
	var regex_expl := RegEx.create_from_string("\\*\\*Penjelasan:\\*\\*\\s*(.+)")
	var regex_key := RegEx.create_from_string("\\*\\*Kunci Jawaban:\\*\\*\\s*Indeks\\s*(\\d+)")
	var regex_order_key := RegEx.create_from_string("\\*\\*Urutan Benar \\(correct_order\\):\\*\\*\\s*\\[(.*?)\\]")

	for i in range(1, sections.size()):
		var sec: String = sections[i]
		var id_match := regex_id.search(sec)
		var layer_match := regex_layer.search(sec)
		var type_match := regex_type.search(sec)
		var q_match := regex_q.search(sec)
		var expl_match := regex_expl.search(sec)

		if not (id_match and layer_match and type_match and q_match and expl_match):
			continue

		var q := QuizQuestion.new()
		var q_id: String = id_match.get_string(1).strip_edges()
		q.layer_id = layer_match.get_string(1).strip_edges()
		q.type = type_match.get_string(1).strip_edges()
		q.question = q_match.get_string(1).strip_edges()
		q.explanation = expl_match.get_string(1).strip_edges()

		if q.type == "mcq" or q.type == "tf":
			var opts_start := sec.find("**Opsi:**")
			var opts_end := sec.find("**Kunci Jawaban:**")
			if opts_start != -1 and opts_end != -1:
				var opts_str := sec.substr(opts_start, opts_end - opts_start)
				for line in opts_str.split("\n"):
					line = line.strip_edges()
					if line.begins_with("1.") or line.begins_with("2.") or line.begins_with("3.") or line.begins_with("4."):
						var opt_text := line.substr(2).strip_edges()
						q.options.append(opt_text)
			var key_m := regex_key.search(sec)
			if key_m:
				q.correct_index = int(key_m.get_string(1))

		elif q.type == "match":
			var left_start := sec.find("**Kolom Kiri (pairs_left):**")
			var right_start := sec.find("**Kolom Kanan (pairs_right):**")
			var expl_start := sec.find("**Penjelasan:**")
			if left_start != -1 and right_start != -1:
				var left_str := sec.substr(left_start, right_start - left_start)
				for line in left_str.split("\n"):
					line = line.strip_edges()
					if line.length() > 2 and line[0] in ["1", "2", "3", "4", "5"] and line[1] == ".":
						q.pairs_left.append(line.substr(2).strip_edges())
			if right_start != -1 and expl_start != -1:
				var right_str := sec.substr(right_start, expl_start - right_start)
				for line in right_str.split("\n"):
					line = line.strip_edges()
					if line.length() > 2 and line[0] in ["1", "2", "3", "4", "5"] and line[1] == ".":
						q.pairs_right.append(line.substr(2).strip_edges())

		elif q.type == "order":
			var item_start := sec.find("**Item Urutan (order_items):**")
			var order_key_start := sec.find("**Urutan Benar (correct_order):**")
			if item_start != -1 and order_key_start != -1:
				var item_str := sec.substr(item_start, order_key_start - item_start)
				for line in item_str.split("\n"):
					line = line.strip_edges()
					if line.length() > 2 and line[0] in ["1", "2", "3", "4", "5", "6"] and line[1] == ".":
						q.order_items.append(line.substr(2).strip_edges())
			var order_m := regex_order_key.search(sec)
			if order_m:
				for num_str in order_m.get_string(1).split(","):
					var trimmed := num_str.strip_edges()
					if not trimmed.is_empty():
						q.correct_order.append(int(trimmed))

		var save_path := out_dir.path_join("%s.tres" % q_id)
		var err := ResourceSaver.save(q, save_path)
		if err == OK:
			count += 1
		else:
			push_error("[import_quiz] Gagal menyimpan resource %s (Error code: %d)" % [save_path, err])

	return count
