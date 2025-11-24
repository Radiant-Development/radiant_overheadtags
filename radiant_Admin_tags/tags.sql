DROP TABLE IF EXISTS `radiant_tags`;

CREATE TABLE `radiant_tags` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    license VARCHAR(255) NOT NULL UNIQUE,
    tag_text VARCHAR(64),
    tag_message VARCHAR(128),
    color_r INT DEFAULT 255,
    color_g INT DEFAULT 255,
    color_b INT DEFAULT 255,
    color_r2 INT DEFAULT 255,
    color_g2 INT DEFAULT 255,
    color_b2 INT DEFAULT 255,
    style VARCHAR(32) DEFAULT 'solid'
);
