import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        siteKeyV2: String,
        siteKeyV3: String,
        recaptchaNet: false,
        version: String,
        action: String,
        fieldName: String,
    };
    static targets = [ "input", "holder" ];

    connect() {
        if (this.versionValue === 'v3') {
            this.holderTarget.dataset.sitekey = this.siteKeyV3Value;
            this.holderTarget.dataset.size = "invisible";
            this.holderTarget.className = "g-recaptcha g-recaptcha-response";
        }

        this.load(this.recaptchaNetValue)
            .then(() => {
                if (this.versionValue === 'v2') {
                    window.grecaptcha.render(this.holderTarget, { sitekey: this.siteKeyV2Value } )
                    console.log($("[name=g-recaptcha-response]"))

                    $("[name=g-recaptcha-response]").attr("name", this.fieldNameValue);
                } else {
                    window.grecaptcha.ready(() => {
                        console.log("grecaptcha ready");


                        window.grecaptcha.execute(undefined, {action: this.actionValue})
                            .then((token) => {
                                this.inputTarget.value = token;
                            })
                    })
                }
        })
    }

    disconnect(){
        window.grecaptcha = undefined;
        this.script?.remove()
    }

    load(recaptchaNet = false) {
        return new Promise((resolve, reject) => {
            console.log("loading recaptcha");

            const { grecaptcha } = window;

            if (grecaptcha) {
                console.log("grecaptcha found");
                resolve();
            }  else {
                this.script = document.createElement('script');

                const handleScriptError = () => {
                    this.script.removeEventListener('error', handleScriptError);
                    reject();
                };

                window.handleRecaptchaLoad = () => {
                    resolve();
                }

                this.script.type = 'text/javascript';
                this.script.src = `https://${(recaptchaNet ? 'www.recaptcha.net' : 'www.google.com')}/recaptcha/api.js?onload=handleRecaptchaLoad`;
                this.script.async = true;
                this.script.defer = true;
                this.script.addEventListener('error', handleScriptError);

                console.log("adding script");

                document.body.appendChild(this.script);
            }
        });
    };
}