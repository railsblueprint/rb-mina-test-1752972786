import { Controller } from "@hotwired/stimulus"
import { useIntersection } from 'stimulus-use'

export default class extends Controller {
  connect() {
    useIntersection(this)
  }

  appear(entry) {
    $(this.element).siblings().removeClass('d-none');
    $(this.element).addClass("d-none");
    this.element.click();
  }
}
