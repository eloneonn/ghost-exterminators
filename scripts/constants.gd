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
    Enums.Item.BATTERY
];

const ITEM_PRICES: Dictionary = {
    Enums.Item.WEAPON1: 100,
    Enums.Item.BATTERY: 10,
};

const ITEM_NAMES: Dictionary = {
    Enums.Item.WEAPON1: "GhostRay 1000",
    Enums.Item.BATTERY: "Battery",
};

## Max battery charge before needing a new battery
const BATTERY_MAX_CHARGE: int = 110;