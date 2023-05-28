
var ctx = document.getElementById('myChart').getContext('2d');
var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: [], // empty array for labels, will be updated dynamically
        datasets: [{
            label: 'Thermocouple_1',
            data: [],
            fill: false,
            borderColor: 'rgb(75, 192, 192)',
            backgroundColor: 'rgb(75, 192, 192)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_2',
            data: [],
            fill: false,
            borderColor: 'rgb(255, 99, 132)', // different color
            backgroundColor: 'rgb(255, 99, 132)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_3',
            data: [],
            fill: false,
            borderColor: 'rgb(54, 162, 235)', // different color
            backgroundColor: 'rgb(54, 162, 235)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_4',
            data: [],
            fill: false,
            borderColor: 'rgb(255, 205, 86)', // different color
            backgroundColor: 'rgb(255, 205, 86)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_5',
            data: [],
            fill: false,
            borderColor: 'rgb(153, 102, 255)', // different color
            backgroundColor: 'rgb(153, 102, 255)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_6',
            data: [],
            fill: false,
            borderColor: 'rgb(255, 159, 64)', // different color
            backgroundColor: 'rgb(255, 159, 64)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_7',
            data: [],
            fill: false,
            borderColor: 'rgb(201, 203, 207)', // different color
            backgroundColor: 'rgb(201, 203, 207)',
            lineTension: 0.1
        },{
            label: 'Thermocouple_8',
            data: [],
            fill: false,
            borderColor: 'rgb(0, 0, 0)', // different color
            backgroundColor: 'rgb(0, 0, 0)',
            lineTension: 0.1
        }]    
    },
    options: {
        scales: {
            xAxes: [{
                type: 'time',
                distribution: 'linear',
                time: {
                    displayFormats: {
                        second: 'h:mm:ss a'
                    }
                }
            }]
        }
    }
});
function epoch_time_to_date_obj(epoch_time)
{
    var utcSeconds = epoch_time;
    var d = new Date(0); 
    d.setUTCMilliseconds(utcSeconds);    
    // d.setUTCSeconds
    return d;
}
function generateData() {
    return Math.floor(Math.random() * 100);
    
    // remove data older than 30 seconds
    // add new data

    
}
function convert_time_string_to_expected_format(timeString) {
    const timeParts = timeString.split(':');
    const hours = timeParts[0].padStart(2, '0');
    const minutes = timeParts[1].padStart(2, '0');
    const seconds = timeParts[2].padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
}

function get_time_diff_in_seconds_from_time_strings(string1, string2) {
    const formattedTime1 = convert_time_string_to_expected_format(string1);
    const formattedTime2 = convert_time_string_to_expected_format(string2);
    const date1 = new Date(`1970-01-01T${formattedTime1}Z`);
    const date2 = new Date(`1970-01-01T${formattedTime2}Z`);
    const timeDiff = date2.getTime() - date1.getTime();
    // console.log(`Time diff between ${formattedTime1} and ${formattedTime2} is ${timeDiff}`);
    return timeDiff/1000;
}
async function get_updated_data_from_flask() {
    // Make an API call to the Flask backend and get the data
    if (myChart.config.type == 'line')
    {
        const response = await fetch('/data_line');
        const data = await response.json();
        myChart.data.labels = data.labels;
        myChart.data.datasets.forEach((dataset, i) => {
            dataset.data = data[`data${i}`];
            document.getElementById("TH_Box_" + (i+1)).innerHTML = data[`data${i}`][`data${i}`.length-1] + "°C";
        });
    }
    else
    {
        const response = await fetch('/data_bar');
        const data = await response.json();
        myChart.data.labels = [];
        myChart.data.labels.push(data.ts);
        myChart.data.datasets.forEach((dataset) => dataset.data = []);
        myChart.data.datasets.forEach((dataset, i) => {
            dataset.data.push(data.data[`th${i+1}`]);
            document.getElementById("TH_Box_" + (i+1)).innerHTML = data.data[`th${i+1}`] + "°C";
          });
    }
    myChart.update();
  }
// update data every second
setInterval(get_updated_data_from_flask, 1000);

$("#button1").click(function() {
    // Change Chart Type here
    if (myChart.config.type == 'line') {
        myChart.config.type = 'bar';
    } else {
        myChart.config.type = 'line';
    }
    
    console.log("Button 1 clicked!");
});

$("#button2").click(function() {
    //Call api to start data logging here
    if (button2.innerHTML == "Start Log")
    {
        button2.innerHTML = "Stop Log";
        button2.class = "press press-red press-round press-ghost press-xl";
        button2.style.backgroundColor = "red";
    }
    else 
    {
        button2.innerHTML = "Start Log";
        button2.class = "press press-bluegrey press-round press-ghost press-xl";
        button2.style.backgroundColor = "white";
    }
    console.log("Button 2 clicked!");
});

window.onload = function() {
    // Show the loading container
    var loadingContainer = document.getElementById("loading-container");
    loadingContainer.style.display = "block";
  
    // Hide the content container
    var contentContainer = document.getElementById("content-container");
    contentContainer.style.display = "none";
  
    // Set the duration for each image (in milliseconds)
    var imageDuration = 3000; // 3 seconds
  
    // Array of image URLs
    var imageUrls = [
      "splash1.png",
      "splash2.png"
    ];
  
    var currentImageIndex = 0;
  
    // Function to display the images
    function displayImages() {
        var image = new Image();
        image.onload = function() {
          // Scale down the image by applying a static scale factor
          var scaleFactor = 0.95;
          var scaledWidth = image.width * scaleFactor;
          var scaledHeight = image.height * scaleFactor;
    
          image.style.width = scaledWidth + "px";
          image.style.height = scaledHeight + "px";
          image.style.position = "absolute";
          image.style.left = "50%";
          image.style.top = "50%";
          image.style.transform = "translate(-50%, -50%)";
    
          loadingContainer.innerHTML = "";
          loadingContainer.appendChild(image);
    
          setTimeout(function() {
            // Display the next image after the specified duration
            currentImageIndex++;
            if (currentImageIndex < imageUrls.length) {
              displayImages();
            } else {
              // After displaying all images, hide the loading container and show the content container
              loadingContainer.style.display = "none";
              contentContainer.style.display = "block";
            }
          }, imageDuration);
        };
        image.src = imageUrls[currentImageIndex];
      }
    
      // Start displaying the images
      displayImages();
    }