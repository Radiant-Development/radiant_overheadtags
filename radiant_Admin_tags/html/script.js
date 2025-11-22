window.addEventListener("message", (event) => {
    if (event.data.action === "open") {
        document.getElementById("menu").style.display = "block";
    }
});

document.getElementById("close").onclick = () => {
    fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
    document.getElementById("menu").style.display = "none";
};

document.getElementById("save").onclick = () => {
    let text = document.getElementById("tagText").value;
    let hex = document.getElementById("color").value;

    const bigint = parseInt(hex.replace("#", ""), 16);
    const r = (bigint >> 16) & 255;
    const g = (bigint >> 8) & 255;
    const b = bigint & 255;

    fetch(`https://${GetParentResourceName()}/saveTag`, {
        method: "POST",
        body: JSON.stringify({ text, r, g, b })
    });

    document.getElementById("menu").style.display = "none";
};
