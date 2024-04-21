import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        $(this.element).modal("show")
    }

    disconnect() {
        $(".modal-backdrop").remove()
    }
}
