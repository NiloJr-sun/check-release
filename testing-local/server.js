const express = require("express");
const bodyParser = require("body-parser");
const { execFile } = require("child_process");

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

app.post("/check-release", (req, res) => {
  const text = req.body.text; // e.g., "1234 my-org/my-repo"
  const [PR_NUMBER, REPO] = text.split(" ");
  if (!PR_NUMBER || !REPO) {
    return res.send("Usage: /check-release [PR_NUMBER] [REPO]");
  }

  execFile("./check-release.sh", [PR_NUMBER, REPO], (error, stdout, stderr) => {
    if (error) {
      console.error(stderr);
      return res.status(500).send("Error running script.");
    }
    res.send(
      `Checking release... Slack should get the update shortly. ${text}`
    );
  });
});

app.listen(3000, () => console.log("Listening on port 3000"));
