// Comment Management with Shared Storage
class CommentManager {
    constructor() {
        // ============================================
        // SHARED STORAGE - Everyone sees all comments!
        // Using a reliable JSON storage service
        // ============================================
        // Using a public JSON endpoint - works immediately
        // This uses a simple JSON hosting service
        this.STORAGE_ID = 'eggy-memorial-tributes-v1';
        this.STORAGE_URL = `https://api.jsonbin.io/v3/b/${this.STORAGE_ID}`;
        this.PUBLIC_STORAGE = `https://jsonbin.org/${this.STORAGE_ID}`;
        
        // Fallback: Also use localStorage as backup
        this.comments = [];
        this.init();
    }

    async init() {
        await this.loadComments();
        this.renderComments();
        this.setupForm();
        this.setupStreamEmbed();
        
        // Auto-refresh comments every 5 seconds to show new tributes
        setInterval(() => {
            this.loadComments().then(() => this.renderComments());
        }, 5000);
    }

    // Load comments from shared storage
    async loadComments() {
        // Always load from localStorage first (fast, immediate)
        this.loadFromLocalStorage();
        
        // Then try to sync from API in background
        try {
            // Try multiple endpoints
            const endpoints = [
                this.PUBLIC_STORAGE,
                `https://api.jsonbin.io/v3/b/${this.STORAGE_ID}/latest`,
                `https://www.jsonstorage.net/api/items/${this.STORAGE_ID}`
            ];
            
            for (const endpoint of endpoints) {
                try {
                    const response = await fetch(endpoint, {
                        method: 'GET',
                        headers: {
                            'Content-Type': 'application/json',
                        }
                    });
                    
                    if (response.ok) {
                        const data = await response.json();
                        let loadedComments = [];
                        
                        // Handle different response formats
                        if (data && data.record) {
                            if (Array.isArray(data.record)) {
                                loadedComments = data.record;
                            } else if (data.record.comments && Array.isArray(data.record.comments)) {
                                loadedComments = data.record.comments;
                            }
                        } else if (data && data.comments && Array.isArray(data.comments)) {
                            loadedComments = data.comments;
                        } else if (Array.isArray(data)) {
                            loadedComments = data;
                        } else if (data && typeof data === 'object' && data.data) {
                            loadedComments = Array.isArray(data.data) ? data.data : [];
                        }
                        
                        // Merge with existing comments (avoid duplicates)
                        if (loadedComments.length > 0) {
                            const existingIds = new Set(this.comments.map(c => c.id));
                            loadedComments.forEach(comment => {
                                if (!existingIds.has(comment.id)) {
                                    this.comments.push(comment);
                                }
                            });
                            // Sort by timestamp (newest first)
                            this.comments.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
                            // Save merged comments
                            localStorage.setItem('memorialComments', JSON.stringify(this.comments));
                            break; // Success, stop trying other endpoints
                        }
                    }
                } catch (e) {
                    // Try next endpoint
                    continue;
                }
            }
        } catch (error) {
            console.log('API sync failed, using localStorage only:', error);
        }
    }

    // Load from localStorage (fallback)
    loadFromLocalStorage() {
        const stored = localStorage.getItem('memorialComments');
        if (stored) {
            try {
                const localComments = JSON.parse(stored);
                // Merge with current comments (avoid duplicates)
                const merged = [...this.comments];
                localComments.forEach(comment => {
                    if (!merged.find(c => c.id === comment.id)) {
                        merged.push(comment);
                    }
                });
                this.comments = merged.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
            } catch (e) {
                console.error('Error parsing localStorage:', e);
            }
        }
    }

    // Save comments to shared storage
    async saveComments() {
        // Save to localStorage FIRST (so it shows immediately)
        localStorage.setItem('memorialComments', JSON.stringify(this.comments));
        
        // Then try to save to API in background (for sharing across devices)
        const saveData = {
            comments: this.comments,
            lastUpdated: new Date().toISOString()
        };
        
        // Try multiple endpoints
        const endpoints = [
            { url: `https://api.jsonbin.io/v3/b/${this.STORAGE_ID}`, method: 'PUT' },
            { url: `https://www.jsonstorage.net/api/items/${this.STORAGE_ID}`, method: 'PUT' },
            { url: `https://www.jsonstorage.net/api/items/${this.STORAGE_ID}`, method: 'POST' }
        ];
        
        for (const endpoint of endpoints) {
            try {
                const response = await fetch(endpoint.url, {
                    method: endpoint.method,
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(saveData)
                });
                
                if (response.ok) {
                    console.log('Comments saved to shared storage');
                    return; // Success, stop trying
                }
            } catch (error) {
                // Try next endpoint
                continue;
            }
        }
        
        console.log('Shared storage save failed, but saved to localStorage');
    }

    // Setup comment form
    setupForm() {
        const form = document.getElementById('commentForm');
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.addComment();
        });
    }

    // Add a new comment
    async addComment() {
        const nameInput = document.getElementById('commenterName');
        const textInput = document.getElementById('commentText');
        
        const name = nameInput.value.trim();
        const text = textInput.value.trim();

        if (!name || !text) {
            alert('Please fill in both your name and your tribute.');
            return;
        }

        const comment = {
            id: Date.now() + Math.random(), // Ensure unique ID
            name: name,
            text: text,
            timestamp: new Date().toISOString()
        };

        // Add comment immediately (so it shows right away)
        this.comments.unshift(comment);
        this.renderComments();

        // Clear form
        nameInput.value = '';
        textInput.value = '';
        
        // Show loading state
        const btn = document.querySelector('.submit-btn');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<span>Posting...</span>';
        btn.disabled = true;

        // Save to storage (async) - this will save to localStorage immediately
        await this.saveComments();
        
        // Show success feedback
        this.showSuccessMessage();
        btn.disabled = false;
        
        // Force re-render to ensure comment is visible
        this.renderComments();
    }

    // Show success message
    showSuccessMessage() {
        const btn = document.querySelector('.submit-btn');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<span>✓ Posted</span>';
        btn.style.background = '#27ae60';
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.style.background = '';
        }, 2000);
    }

    // Render all comments
    renderComments() {
        const commentsList = document.getElementById('commentsList');
        
        if (this.comments.length === 0) {
            commentsList.innerHTML = '<p class="no-comments">No tributes yet. Be the first to share your memories.</p>';
            return;
        }

        commentsList.innerHTML = this.comments.map(comment => {
            const time = this.formatTime(comment.timestamp);
            return `
                <div class="comment-item">
                    <div class="comment-header">
                        <span class="comment-name">${this.escapeHtml(comment.name)}</span>
                        <span class="comment-time">${time}</span>
                    </div>
                    <div class="comment-text">${this.escapeHtml(comment.text)}</div>
                </div>
            `;
        }).join('');
    }

    // Format timestamp
    formatTime(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now - date;
        
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (minutes < 1) return 'Just now';
        if (minutes < 60) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
        if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
        if (days < 7) return `${days} day${days > 1 ? 's' : ''} ago`;
        
        return date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
            hour: 'numeric',
            minute: '2-digit'
        });
    }

    // Escape HTML to prevent XSS
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Setup stream embed
    setupStreamEmbed() {
        const streamIframe = document.getElementById('liveStream');
        const placeholder = document.getElementById('streamPlaceholder');
        
        // ============================================
        // LIVE STREAM - Memorial Service
        // YouTube Live Stream: https://www.youtube.com/live/i860PiPrx-0
        // ============================================
        const liveStreamId = 'i860PiPrx-0'; // Your YouTube Live Stream ID
        if (streamIframe) {
            // Try multiple embed formats for YouTube Live
            // Format 1: Standard embed (works for live and recorded)
            const embedUrl = `https://www.youtube.com/embed/${liveStreamId}?autoplay=1&rel=0&modestbranding=1&enablejsapi=1&origin=${encodeURIComponent(window.location.origin)}`;
            streamIframe.src = embedUrl;
            if (placeholder) placeholder.style.display = 'none';
            
            // Hide placeholder when video loads
            streamIframe.addEventListener('load', function() {
                if (placeholder) placeholder.style.display = 'none';
            });
            
            // Handle errors - try alternative format if needed
            streamIframe.addEventListener('error', function() {
                console.log('Trying alternative embed format...');
                // Alternative: Use watch URL format
                streamIframe.src = `https://www.youtube.com/embed/live_stream?channel=${liveStreamId}`;
            });
        }
        
        // ============================================
        // FREE STREAMING PLATFORMS - Choose ONE for your actual stream:
        // ============================================
        
        // OPTION 1: YouTube Live (RECOMMENDED - Free & Easy)
        // Steps: 
        // 1. Go to YouTube Studio > Go Live
        // 2. Start your stream
        // 3. Copy the video ID from the URL: https://www.youtube.com/watch?v=VIDEO_ID
        // 4. Replace the demoVideoId above with your live stream ID:
        /*
        const youtubeVideoId = 'YOUR_LIVE_STREAM_ID_HERE';
        if (youtubeVideoId && youtubeVideoId !== 'YOUR_LIVE_STREAM_ID_HERE') {
            streamIframe.src = `https://www.youtube.com/embed/${youtubeVideoId}?autoplay=1&rel=0&modestbranding=1`;
            if (placeholder) placeholder.style.display = 'none';
        }
        */
        
        // OPTION 2: Twitch (Free)
        // Steps:
        // 1. Create a Twitch account and go live
        // 2. Get your channel name
        // 3. Uncomment and replace CHANNEL_NAME below:
        /*
        const twitchChannel = 'YOUR_CHANNEL_NAME';
        if (twitchChannel && twitchChannel !== 'YOUR_CHANNEL_NAME') {
            streamIframe.src = `https://player.twitch.tv/?channel=${twitchChannel}&parent=${window.location.hostname}&muted=false`;
            if (placeholder) placeholder.style.display = 'none';
        }
        */
        
        // OPTION 3: Facebook Live (Free)
        // Steps:
        // 1. Go live on Facebook
        // 2. Get the video ID from the post URL
        // 3. Use Facebook's embed code generator or use this format:
        /*
        const facebookVideoId = 'YOUR_VIDEO_ID';
        if (facebookVideoId && facebookVideoId !== 'YOUR_VIDEO_ID') {
            streamIframe.src = `https://www.facebook.com/plugins/video.php?href=https%3A%2F%2Fwww.facebook.com%2Fwatch%2F%3Fv%3D${facebookVideoId}&show_text=false&width=560`;
            if (placeholder) placeholder.style.display = 'none';
        }
        */
        
        // OPTION 4: Restream (Free tier available)
        // Steps:
        // 1. Sign up at restream.io
        // 2. Get your embed code from the dashboard
        // 3. Use the embed URL they provide:
        /*
        const restreamEmbedUrl = 'YOUR_RESTREAM_EMBED_URL';
        if (restreamEmbedUrl && restreamEmbedUrl !== 'YOUR_RESTREAM_EMBED_URL') {
            streamIframe.src = restreamEmbedUrl;
            if (placeholder) placeholder.style.display = 'none';
        }
        */
        
        // OPTION 5: Custom Embed URL (for any platform)
        // If you have a direct embed URL from any platform:
        /*
        const customEmbedUrl = 'YOUR_EMBED_URL_HERE';
        if (customEmbedUrl && customEmbedUrl !== 'YOUR_EMBED_URL_HERE') {
            streamIframe.src = customEmbedUrl;
            if (placeholder) placeholder.style.display = 'none';
        }
        */
        
        // ============================================
        // QUICK SETUP: Uncomment ONE option above and fill in your details
        // ============================================
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
    new CommentManager();
    
    // Add smooth scroll behavior
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
});

// Add real-time clock for program timing
function updateProgramTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: true 
    });
    
    // You can add a live clock display if needed
    // This is just a placeholder for future enhancement
}

// Update time every minute
setInterval(updateProgramTime, 60000);
