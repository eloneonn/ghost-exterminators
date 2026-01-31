class_name Constants
## How much money is lost when a prop is destroyed
const BASE_PROP_DESTRUCTION_PENALTY: int = 100;

## How much money is rewarded when a ghost is killed
const BASE_GHOST_CAPTURE_REWARD: int = 100;

## How much money is rewarded for finishing the quota ahead of time
const BASE_TIME_BONUS: int = 200;

## Base salary for the player paid every day
const BASE_SALARY: int = 300;

const STARTING_MONEY: int = 500;

const STARTING_QUOTA: int = 5;

const STARTING_INVENTORY: Array[Enums.Item] = [
    Enums.Item.WEAPON1,
    Enums.Item.BATTERY,
    Enums.Item.BATTERY, 
    Enums.Item.BETTER_FLASHLIGHT
];

static var ITEM_PRICES: Dictionary = {
    Enums.Item.WEAPON1: 100,
    Enums.Item.BATTERY: 10,
    Enums.Item.GUN_DAMAGE: 250,
    Enums.Item.GUN_RANGE: 200,
    Enums.Item.GUN_COOLING: 220,
    Enums.Item.PLAYER_SPEED: 180,
    Enums.Item.PLAYER_BATTERY: 150,
};

static var ITEM_NAMES: Dictionary = {
    Enums.Item.WEAPON1: "GhostRay 1000",
    Enums.Item.BATTERY: "Battery",
    Enums.Item.GUN_DAMAGE: "GhostRay Damage Mod",
    Enums.Item.GUN_RANGE: "GhostRay Range Mod",
    Enums.Item.GUN_COOLING: "GhostRay Cooling Mod",
    Enums.Item.PLAYER_SPEED: "Lightweight Boots",
    Enums.Item.PLAYER_BATTERY: "High-Capacity Battery Pack",
};

## Max battery charge before needing a new battery
const BATTERY_MAX_CHARGE: int = 60;

## Upgrade bonuses
const UPGRADE_GUN_DAMAGE_BONUS: float = 110.0
const UPGRADE_GUN_RANGE_BONUS: float = 30.0
const UPGRADE_GUN_WIDTH_BONUS: float = -200.0
const UPGRADE_GUN_MAX_HEAT_BONUS: float = 30.0
const UPGRADE_GUN_COOL_RATE_BONUS: float = 12.0
const UPGRADE_GUN_HEAT_RATE_REDUCTION: float = 6.0

const UPGRADE_PLAYER_SPEED_BONUS: float = 50.0
const UPGRADE_PLAYER_BATTERY_BONUS: int = 40

## Sanity lost per second when flashlight is out (no charge and no spare batteries)
const SANITY_BLEED_NO_FLASHLIGHT: int = 3
