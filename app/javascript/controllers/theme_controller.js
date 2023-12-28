import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    connect() {
        this.setCurrentTheme()
        this.showActiveTheme()
        this.watchGlobalTheme()
    }

    disconnect() {
        this.unwatchGlobalTheme()
    }

    set({params: {theme} }) {
        this.setPreferredTheme(theme)
        this.setCurrentTheme()
        this.showActiveTheme()
    }

    getPreferredTheme()  {
        return  localStorage.getItem('theme') || 'auto'
    }

    setPreferredTheme(theme) {
        localStorage.setItem('theme', theme)
    }

    getCurrentTheme() {
        const theme =  this.getPreferredTheme()

        if (theme === 'auto') {
            return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
        } else {
            return theme;
        }
    }

    setCurrentTheme() {
      document.documentElement.setAttribute('data-bs-theme', this.getCurrentTheme())
    }

    showActiveTheme() {
        const theme = this.getPreferredTheme()

        $('[data-theme-theme-param]').removeClass('active')
        $(`[data-theme-theme-param="${theme}"]`).addClass('active')
    }


    unwatchGlobalTheme() {
        this.mediaMatcher.removeEventListener('change', this.boundWatcher)
    }

    watchGlobalTheme() {
        this.boundWatcher =  this.onGlobalThemeChange.bind(this);
        this.mediaMatcher = window.matchMedia('(prefers-color-scheme: dark)')
        this.mediaMatcher.addEventListener('change', this.boundWatcher)
    }

    onGlobalThemeChange() {
        if (this.getPreferredTheme() === 'auto') {
            this.setCurrentTheme()
        }
    }
}
