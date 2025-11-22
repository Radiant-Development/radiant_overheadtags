-- -----------------------------------------------------
--   R A D I A N T   D E V E L O P M E N T
--   Overhead Tags System – SQL Schema
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `radiant_tags` (
    `id` INT NOT NULL AUTO_INCREMENT,

    -- Player license (FiveM identifier)
    `license` VARCHAR(255) NOT NULL UNIQUE,

    -- Main tag (chosen from dropdown)
    `role_text` VARCHAR(255) DEFAULT NULL,

    -- Sub-message (custom user input)
    `message_text` VARCHAR(255) DEFAULT NULL,

    -- Primary color (RGB)
    `color_r` INT DEFAULT 255,
    `color_g` INT DEFAULT 255,
    `color_b` INT DEFAULT 255,

    -- Secondary color (RGB) – used for gradients
    `color_r2` INT DEFAULT 255,
    `color_g2` INT DEFAULT 255,
    `color_b2` INT DEFAULT 255,

    -- Style (solid, lr, pulse, outline)
    `style` VARCHAR(50) DEFAULT 'solid',

    PRIMARY KEY (`id`)
);

