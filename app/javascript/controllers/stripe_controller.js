import { loadStripe } from '@stripe/stripe-js';
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["stripeToken", "cardElement", "cardErrors"];

    connect() {
        const stripeKey = this.element.dataset.stripeKey;
        loadStripe(stripeKey).then(stripe => {
            this.stripe = stripe;
            const elements = stripe.elements();

            this.card = elements.create('card');
            this.card.mount(this.cardElementTarget);
            this.card.addEventListener('change', this.cardChanged.bind(this));
        })
    }

    cardChanged(event) {
        if (event.error) {
            this.cardErrorsTarget.textContent = event.error.message;
        } else {
            this.cardErrorsTarget.textContent = '';
        }
    }

    submit(event) {
        console.log("submit");
        event.preventDefault();

        this.stripe.createToken(this.card).then(this.tokenCreated.bind(this));
    }

    tokenCreated(result) {
        console.log(result);
        if (result.error) {
            // Inform the user if there was an error.
            this.cardErrorsTarget.textContent = result.error.message;
        } else {
            // Send the token to your server.
            this.stripeTokenTarget.value = result.token.id;
            this.element.submit();
        }
    }
}
