extends Node
# Config.gd — Seluruh angka dan konstanta gameplay terpusat (Sesuai PROJECT_BRIEF.md Bagian 2.1)

# ── Gerak Dasar ────────────────────────────────────────────
const SPEED           : float = 220.0
const JUMP_V          : float = -480.0
const DOUBLE_JUMP_V   : float = -420.0
const GRAVITY         : float = 1200.0
const COYOTE          : float = 0.14
const JUMP_BUFFER     : float = 0.14

# ── Dash ───────────────────────────────────────────────────
const DASH_SPEED      : float = 580.0
const DASH_TIME       : float = 0.16
const DASH_COOLDOWN   : float = 0.5
const DASH_IFRAME     : float = 0.2

# ── Energy & Integrity ─────────────────────────────────────
const MAX_ENERGY            : float = 100.0
const ENERGY_REGEN          : float = 8.0
const ENERGY_REGEN_DELAY    : float = 2.0
const ENERGY_COST_DASH      : float = 20.0
const ENERGY_COST_DJ        : float = 15.0

const INITIAL_INTEGRITY     : int   = 3
const MAX_INTEGRITY         : int   = 6
const HURT_COOLDOWN         : float = 1.0
const DEATH_OVERLAY_DURATION: float = 1.5

# ── Magnet & Item ──────────────────────────────────────────
const COIN_MAGNET_DEFAULT   : float = 90.0
const COIN_MAGNET_UPGRADED  : float = 160.0
const BOOSTER_SPEED_MULT    : float = 1.2
const BOOSTER_JUMP_MULT     : float = 1.1
const BOOSTER_DURATION      : float = 8.0
const ENERGY_CELL_RESTORE   : float = 40.0
const COIN_BW_MIN           : int   = 5
const COIN_BW_MAX           : int   = 10
const HEART_HEAL_AMOUNT     : int   = 1
const ARTIFACT_EXP          : int   = 100
const PORT_KEY_EXP          : int   = 50

# ── Musuh & Pertarungan ───────────────────────────────────
const ENEMY_KILL_EXP        : int   = 10
const ENEMY_STOMP_BOUNCE    : float = -340.0
const TURRET_FIRE_INTERVAL  : float = 2.0
const TURRET_DETECT_RANGE   : float = 380.0
const PROJECTILE_SPEED      : float = 140.0
const PROJECTILE_DAMAGE     : int   = 1

# ── Hazards & Rintangan ───────────────────────────────────
const HAZARD_DAMAGE         : int   = 1
const LASER_WARN_TIME       : float = 0.5
const SPARK_DEFAULT_ON      : float = 1.5
const SPARK_DEFAULT_OFF     : float = 1.5
const LASER_DEFAULT_ON      : float = 2.0
const LASER_DEFAULT_OFF     : float = 2.0

# ── Kuis (Quiz) ───────────────────────────────────────────
const QUIZ_EXP_FIRST_TRY     : int   = 150
const QUIZ_BW_FIRST_TRY      : int   = 20
const QUIZ_EXP_RETRY         : int   = 75
const QUIZ_BW_RETRY          : int   = 10
const QUIZ_STREAK_TARGET     : int   = 3
const QUIZ_STREAK_BONUS_EXP  : int   = 100
const QUIZ_DAMAGE_WRONG      : int   = 1
const QUIZ_BUTTON_MIN_HEIGHT : float = 56.0

# ── Toko (Shop) ───────────────────────────────────────────
const SHOP_PRICE_SHIELD       : int   = 40
const SHOP_PRICE_INTEGRITY    : int   = 60
const SHOP_PRICE_HINT         : int   = 25
const SHOP_PRICE_DOUBLE_JUMP  : int   = 100
const SHOP_PRICE_DASH         : int   = 90
const SHOP_PRICE_MAGNET       : int   = 80

# ── Sistem Carry Item & Slot ──────────────────────────────────────────
const CARRY_ITEM_OFFSET_Y          : float = -42.0
const CARRY_SLOT_FEEDBACK_DURATION : float = 2.0

# ── Platform Bergerak ────────────────────────────────────────────────
const MOVING_PLATFORM_DEFAULT_SPEED : float = 55.0
const MOVING_PLATFORM_DEFAULT_PAUSE : float = 0.5

# ── Session Tower (L5) ────────────────────────────────────────────────
const SESSION_TOWER_DURATION        : float = 60.0
const KEEP_ALIVE_BONUS_TIME         : float = 10.0


