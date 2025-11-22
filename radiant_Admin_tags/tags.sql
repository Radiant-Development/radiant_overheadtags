CREATE TABLE IF NOT EXISTS `radiant_tags` (
    id INT NOT NULL AUTO_INCREMENT,
    license VARCHAR(255) NOT NULL,
    tag_text VARCHAR(255) DEFAULT NULL,
    sub_message VARCHAR(255) DEFAULT NULL,
    color_r INT DEFAULT 255,
    color_g INT DEFAULT 255,
    color_b INT DEFAULT 255,
    color_r2 INT DEFAULT 255,
    color_g2 INT DEFAULT 255,
    color_b2 INT DEFAULT 255,
    style VARCHAR(50) DEFAULT 'solid',
    PRIMARY KEY (id),
    UNIQUE KEY license_unique (license)
);
