// Listen for UI open
window.addEventListener("message", (event) => {
    if (event.data.action === "open") {

        document.getElementById("menu").style.display = "block";
        document.getElementById("errorBox").innerText = "";

        // Populate roles
        const dropdown = document.getElementById("roleDropdown");
        dropdown.innerHTML = "";

        const roles = event.data.roles || [];
        if (roles.length === 0) {
            let opt = document.createElement("option");
            opt.value = "";
            opt.textContent = "No available tags";
            dropdown.appendChild(opt);
        } else {
            roles.forEach(role => {
                let opt = document.createElement("option");
                opt.value = role.value;
                opt.textContent = role.text;
                dropdown.appendChild(opt);
            });
        }
    }
});

// Cancel button
document.getElementById("cancel").onclick = () => {
    document.getElementById("menu").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
};

// Style selection logic
document.getElementById("style").onchange = () => {
    const style = document.getElementById("style").value;
    document.getElementById("secondaryColorSection").style.display =
        style === "lr" ? "block" : "none";
};

// Save tag
document.getElementById("save").onclick = () => {

    const role = document.getElementById("roleDropdown").value;
    const message = document.getElementById("subMessage").value.trim();
    const style = document.getElementById("style").value;

    if (!role || role.length === 0)
        return showError("You must select a tag.");

    if (message.length > 48)
        return showError("Message must be under 48 characters.");

    // Convert HEX → RGB
    const hexToRGB = (hex) => {
        const n = parseInt(hex.replace("#", ""), 16);
        return {
            r: (n >> 16) & 255,
            g: (n >> 8) & 255,
            b: n & 255
        };
    };

    const c1 = hexToRGB(document.getElementById("color1").value);
    const c2 = hexToRGB(document.getElementById("color2").value);

    fetch(`https://${GetParentResourceName()}/saveTag`, {
        method: "POST",
        body: JSON.stringify({
            role,
            message,
            style,
            r: c1.r, g: c1.g, b: c1.b,
            r2: c2.r, g2: c2.g, b2: c2.b
        })
    });

    document.getElementById("menu").style.display = "none";
};

// Error bubble
function showError(msg) {
    document.getElementById("errorBox").innerText = msg;
}
