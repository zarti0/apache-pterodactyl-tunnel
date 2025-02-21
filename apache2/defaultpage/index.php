<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="logo.png" type="image/png">
    <title>Welcome</title>
    <style>
        body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            width: 100%;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #0d0d0d;
            color: #fff;
            font-family: 'Courier New', Courier, monospace;
            position: relative;
            text-align: center;
        }

        .canvas-container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
        }

        #code-text {
            font-size: 20px;
            z-index: 2;
            position: relative;
            display: flex;
            flex-direction: column;
        }

        table {
            margin: 20px auto;
            border-collapse: collapse;
            width: 80%;
            color: #ffffff;
            text-align: left;
            font-size: 18px;
        }

        table th, table td {
            border: 1px solid #4CAF50;
            padding: 8px;
        }

        /* Responsive design for mobile */
        @media (max-width: 600px) {
            #code-text h1 {
                font-size: 16px;
            }
        }

        /* Rainbow text animation */
        @keyframes rainbow {
            0% { color: #ff0000; }
            20% { color: #ffa500; }
            40% { color: #ffff00; }
            60% { color: #008000; }
            80% { color: #0000ff; }
            100% { color: #ee82ee; }
        }

        /* Cursor blink effect */
        @keyframes blink {
            50% {
                border-color: transparent;
            }
        }

        /* Apply the rainbow animation to each line with a delay */
        #line1, #line2, #line3 {
            animation: rainbow 5s infinite, blink 1s step-end infinite alternate;
        }

        #line1 { animation-delay: 0s; }
        #line2 { animation-delay: 5s; }
        #line3 { animation-delay: 10s; }

        a {
            color: #4CAF50;
            margin-top: 20px;
            display: inline-block;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <canvas class="canvas-container" id="canvas"></canvas>

    <div id="code-text">
        <h1 id="line1">Welcome to</h1>
        <h1 id="line2">Your Apache2 App</h1>
        <h1 id="line3">Thank You for Choosing Tunnels with Love ♥♥♥♥♥</h1>
        <a href="https://discord.tunnels.my">Go to FAQ</a>
        <a style="text-decoration: none; color: inherit;">Your Domain is</a>
        <a target="_blank" href="https://<?php echo $_SERVER['SERVER_NAME']; ?>" style="text-decoration: none; color: red;"><?php echo strtoupper($_SERVER['SERVER_NAME']); ?></a>
        
        <!-- PHP Info Table -->
        <table>
            <tr>
                <th>PHP Info</th>
                <th>Details</th>
            </tr>
            <tr>
                <td>PHP Version</td>
                <td><?php echo phpversion(); ?></td>
            </tr>
            <tr>
                <td>PHP-FPM Version</td>
                <td><?php echo php_sapi_name(); ?></td>
            </tr>
            <tr>
                <td>Loaded PHP Modules</td>
                <td><?php echo implode(', ', get_loaded_extensions()); ?></td>
            </tr>
            <tr>
                <td>Zend Engine Version</td>
                <td><?php echo zend_version(); ?></td>
            </tr>
            <tr>
                <td>Zend Extensions</td>
                <td><?php 
                    $zend_extensions = get_loaded_extensions(true);
                    echo implode(', ', $zend_extensions); 
                ?></td>
            </tr>
            <tr>
                <td>Registered PHP Streams</td>
                <td><?php echo implode(', ', stream_get_wrappers()); ?></td>
            </tr>
            <tr>
                <td>Registered Socket Transports</td>
                <td><?php echo implode(', ', stream_get_transports()); ?></td>
            </tr>
        </table>
    </div>

    <script>
        // Canvas for particles with green, white, and red
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const particlesArray = [];
        const numberOfParticles = 100;

        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 5 + 1;
                this.speedX = Math.random() * 3 - 1.5;
                this.speedY = Math.random() * 3 - 1.5;
                this.color = this.getRandomColor();
            }

            // Randomly choose between green, white, and red
            getRandomColor() {
                const colors = ['#FF0000', '#FFFFFF', '#008000'];
                return colors[Math.floor(Math.random() * colors.length)];
            }

            update() {
                this.x += this.speedX;
                this.y += this.speedY;

                if (this.x > canvas.width || this.x < 0) {
                    this.speedX = -this.speedX;
                }
                if (this.y > canvas.height || this.y < 0) {
                    this.speedY = -this.speedY;
                }
            }

            draw() {
                ctx.fillStyle = this.color;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.closePath();
                ctx.fill();
            }
        }

        function init() {
            for (let i = 0; i < numberOfParticles; i++) {
                particlesArray.push(new Particle());
            }
        }

        function connectParticles() {
            let opacityValue = 1;
            for (let a = 0; a < particlesArray.length; a++) {
                for (let b = a; b < particlesArray.length; b++) {
                    let distance = ((particlesArray[a].x - particlesArray[b].x) ** 2) + ((particlesArray[a].y - particlesArray[b].y) ** 2);
                    if (distance < (canvas.width / 7) * (canvas.height / 7)) {
                        opacityValue = 1 - (distance / 20000);
                        ctx.strokeStyle = `rgba(255, 255, 255, ${opacityValue})`;
                        ctx.lineWidth = 1;
                        ctx.beginPath();
                        ctx.moveTo(particlesArray[a].x, particlesArray[a].y);
                        ctx.lineTo(particlesArray[b].x, particlesArray[b].y);
                        ctx.stroke();
                    }
                }
            }
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            for (let i = 0; i < particlesArray.length; i++) {
                particlesArray[i].update();
                particlesArray[i].draw();
            }
            connectParticles();
            requestAnimationFrame(animate);
        }

        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        });

        init();
        animate();
    </script>
</body>
</html>
