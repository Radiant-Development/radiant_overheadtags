// ROLE DROPDOWN + MESSAGE SUPPORT + DYNAMIC POPULATION

// Listen for open event from Lua
window.addEventListener("message", (event) => {
    if (event.data.action === "open") {

        // Show menu
        document.getElementById("menu").style.display = "block";
        document.getElementById("errorBox").innerText = "";

        // Populate role dropdown
        const roles = event.data.roles || [];
        const dropdown = document.getElementById("roleDropdown");
        dropdown.innerHTML = ""; // clear old

        if (roles.length === 0) {
            const opt = document.createElement("option");
            opt.textContent = "No eligible tags available";
            opt.value = "";
            dropdown.appendChild(opt);
        } else {
            roles.forEach(role => {
                const opt = document.createElement("option");
                opt.value = role.value;    // The tag text (DEV, LSPD Officer)
                opt.textContent = role.text; 
                dropdown.appendChild(opt);
            });
        }
    }
});

// Close UI
document.getElementById("cancel").onclick = () => {
    document.getElementById("menu").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
};

// Show/Hide secondary color picker based on style
document.getElementById("style").onchange = () => {
    const style = document.getElementById("style").value;
    document.getElementById("secondaryColorSection").style.display =
        style === "lr" ? "block" : "none";
};

// Save Tag
document.getElementById("save").onclick = () => {
    const role = document.getElementById("roleDropdown").value.trim();
    const message = document.getElementById("subMessage").value.trim();
    const style = document.getElementById("style").value;
    const color1 = document.getElementById("color1").value;
    const color2 = document.getElementById("color2").value;

    if (!role || role.length === 0) {
        return ShowError("You must pick a tag from the dropdown.");
    }

    if (message.length > 48) {
        return ShowError("Sub-message cannot exceed 48 characters.");
    }

    // Convert hex → RGB
    function hexToRGB(hex) {
        const n = parseInt(hex.replace("#", ""), 16);
        return {
            r: (n >> 16) & 255,
            g: (n >> 8) & 255,
            b: n & 255
        };
    }

    const c1 = hexToRGB(color1);
    const c2 = hexToRGB(color2);

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
function ShowError(msg) {
    document.getElementById("errorBox").innerText = msg;
}
