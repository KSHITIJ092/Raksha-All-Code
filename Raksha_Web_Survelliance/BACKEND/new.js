const axios = require("axios");

axios({
    method: "POST",
    url: "https://detect.roboflow.com/fight-detection/2",
    params: {
        api_key: "78OBWzNcdTChiK7Dfbk1",
        image: "IMAGE_URL"
    }
})
.then(function(response) {
    console.log(response.data);
})
.catch(function(error) {
    console.log(error.message);
});