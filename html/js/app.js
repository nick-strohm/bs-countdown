const { createApp, reactive, computed, onMounted } = Vue;

createApp({
    setup() {
        const timers = reactive({});

        const formatTime = (totalSeconds) => {
            if (isNaN(totalSeconds) || totalSeconds < 0) return '00:00';
            const hours = Math.floor(totalSeconds / 3600);
            const minutes = Math.floor((totalSeconds % 3600) / 60);
            const seconds = Math.floor(totalSeconds % 60);

            const pad = (num) => String(num).padStart(2, '0');

            if (hours > 0) {
                return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
            }
            return `${pad(minutes)}:${pad(seconds)}`;
        };

        const showTimerVue = (data) => {
            timers[data.displayId] = {
                displayId: data.displayId,
                title: data.title && data.title.trim() !== '' ? data.title : 'Countdown',
                timeLeft: data.duration,
                timeLeftFormatted: formatTime(data.duration),
                position: data.position || { top: 25, right: 3 },
                isFlashing: false,
                flashColor: data.flashColor || '#ff0000',
                opacity: 0,
                timerId: data.timerId 
            };
            
            requestAnimationFrame(() => {
                if (timers[data.displayId]) {
                    timers[data.displayId].opacity = 1;
                }
            });
        };

        const updateTimerVue = (data) => {
            const timer = timers[data.displayId];
            if (timer) {
                timer.timeLeft = data.timeLeft;
                timer.timeLeftFormatted = formatTime(data.timeLeft);
                if (data.flash !== undefined) {
                    timer.isFlashing = data.flash;
                }
                if (data.flashColor) {
                    timer.flashColor = data.flashColor;
                }
            }
        };

        const hideTimerVue = (data) => {
            const timer = timers[data.displayId];
            if (timer) {
                timer.opacity = 0;
                setTimeout(() => {
                    delete timers[data.displayId];
                }, data.fadeOut || 500); 
            }
        };

        const playSoundVue = (volume) => {
            const audio = new Audio('sounds/timer_end.mp3'); 
            audio.volume = volume !== undefined ? volume : 0.5;
            const playPromise = audio.play();
            if (playPromise !== undefined) {
                playPromise.catch(error => {
                    console.error('Error playing sound:', error);
                    if (error && error.name) console.error('Error Name:', error.name);
                    if (error && error.message) console.error('Error Message:', error.message);
                });
            }
        };

        const handleNuiMessage = (event) => {
            const data = event.data;
            if (!data || !data.action) return;

            switch (data.action) {
                case 'showTimer':
                    showTimerVue(data);
                    break;
                case 'updateTimer':
                    updateTimerVue(data);
                    break;
                case 'hideTimer':
                    hideTimerVue(data);
                    break;
                case 'playSound':
                    playSoundVue(data.volume);
                    break;
            }
        };

        onMounted(() => {
            window.addEventListener('message', handleNuiMessage);
        });

        const timerList = computed(() => Object.values(timers));

        return {
            timers: timerList,
        };
    }
}).mount('#app');
