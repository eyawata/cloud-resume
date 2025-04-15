fetch("https://vzcgputay2.execute-api.ap-northeast-1.amazonaws.com/prod/VisitorCounter")
    .then(response => {
        if (!response.ok) {
            throw new Error("Network response was not OK");
        }
        return response.json();
    })
    .then(data => {
        document.getElementById("visitor-count-value").textContent = data["visitorcount"];
    })
    .catch(error => {
        console.error("Failed to fetch visitor count:", error);
    });