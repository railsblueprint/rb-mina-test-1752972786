import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  hide() {
    $("html").toggleClass("sidebar-hidden");
  }
  show() {
    $("body").toggleClass("sidebar-shown");
  }
}
