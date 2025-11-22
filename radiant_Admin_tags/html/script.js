// Listen for open event from the LUA side
window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        document.getElementById("menu").style.display = "block";
        document.getElementById("errorBox").innerText = "";

        const dropdown = document.getElementById("roleDropdown");
        dropdown.innerHTML = "";

        const roles = event.data.roles || [];

        if (roles.length === 0) {
            const opt = document.createElement("option");
            opt.textContent = "No available tags";
            opt.value = "";
            dropdown.appendChild(opt);
        } else {
            roles.forEach(role => {
                const opt = document.createElement("option");
                opt.value = role.value;
                opt.textContent = role.text;
                dropdown.appendChild(opt);
            });
        }
    }
});

// CLOSE UI
document.getElementById("cancel").onclick = () => {
    document.getElementById("menu").style.display = "none";

    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST"
    });
};

// SHOW/HIDE secondary color input
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

    if (!role) {
        return ShowError("Select a role from the list.");
    }

    if (message.length > 48) {
        return ShowError("Sub-message cannot exceed 48 characters.");
    }

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

function ShowError(msg) {
    document.getElementById("errorBox").innerText = msg;
}
