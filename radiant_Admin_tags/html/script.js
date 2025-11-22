// Listen for open event from Lua
window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        document.getElementById("menu").style.display = "block";
        document.getElementById("errorBox").innerText = "";
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
    const text = document.getElementById("tagText").value.trim();
    const style = document.getElementById("style").value;
    const color1 = document.getElementById("color1").value;
    const color2 = document.getElementById("color2").value;

    // Input validation
    if (text.length === 0) {
        return ShowError("Tag text cannot be empty.");
    }
    if (text.length > 24) {
        return ShowError("Tag cannot exceed 24 characters.");
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
            text,
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
