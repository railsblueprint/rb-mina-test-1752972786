import 'jquery.global'
import * as bootstrap from "bootstrap"
import "@hotwired/turbo-rails";
import 'channels';
import "controllers";
import "trix";
import "@rails/actiontext";

$(function() {
  var toastElList = [].slice.call(document.querySelectorAll('.toast'))
  var toastList = toastElList.map(function (toastEl) {
    $(toastEl).toast("show");
  })

  $("[data-bs-toggle=\"tooltip\"]").tooltip();

  // Needed to enable link inside button
  $(".action-edit-set").click((e) => {
    const target = e.currentTarget;
    Turbo.visit(target.href);
  })

  $(".alert").alert();

})
