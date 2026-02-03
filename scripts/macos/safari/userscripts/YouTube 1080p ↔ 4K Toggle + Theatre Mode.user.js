// ==UserScript==
// @name         YouTube 1080p ↔ 4K Toggle + Theatre Mode
// @namespace    safari-userscripts-yt-quality
// @version      1.1
// @description  Toggle between 1080p and 4K with fallback (q) and default to Theatre Mode
// @match        https://www.youtube.com/*
// @grant        none
// ==/UserScript==

(() => {
    'use strict';

    /* -------------------- THEATRE MODE -------------------- */

    function enableTheatreMode() {
        const player = document.getElementById('movie_player');
        if (!player) return;

        // Avoid toggling repeatedly
        if (!player.classList.contains('ytp-theater-mode')) {
            player.dispatchEvent(new KeyboardEvent('keydown', {
                key: 't',
                code: 'KeyT',
                bubbles: true
            }));
        }
    }

    /* -------------------- QUALITY TOGGLING -------------------- */

    function getPlayer() {
        return document.getElementById('movie_player');
    }

    function pickBestQuality(available, preferredOrder) {
        return preferredOrder.find(q => available.includes(q)) || null;
    }

    function toggleQuality() {
        const player = getPlayer();
        if (!player || !player.getAvailableQualityLevels) return;

        const available = player.getAvailableQualityLevels();
        const current = player.getPlaybackQuality();

        const FOUR_K_CHAIN = ['highres', 'hd2160', 'hd1440', 'hd1080', 'hd720'];
        const HD_CHAIN     = ['hd1080', 'hd720', 'large', 'medium'];

        const isHighRes = ['highres', 'hd2160', 'hd1440'].includes(current);
        const targetChain = isHighRes ? HD_CHAIN : FOUR_K_CHAIN;

        const chosen = pickBestQuality(available, targetChain);
        if (!chosen) return;

        player.setPlaybackQualityRange(chosen);
        player.setPlaybackQuality(chosen);

        console.log('[YT Userscript] Quality set to:', chosen);
    }

    /* -------------------- KEYBOARD SHORTCUT -------------------- */

    document.addEventListener('keydown', (e) => {
        if (e.code === 'KeyQ' && !e.repeat) {
            toggleQuality();
        }
    });

    /* -------------------- PAGE & SPA NAVIGATION -------------------- */

    // Initial load
    setTimeout(enableTheatreMode, 1500);

    // YouTube is a SPA — watch for navigation changes
    let lastUrl = location.href;
    new MutationObserver(() => {
        if (location.href !== lastUrl) {
            lastUrl = location.href;
            setTimeout(enableTheatreMode, 1500);
        }
    }).observe(document.body, { childList: true, subtree: true });

})();
