// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'jquery.global'
import * as bootstrap from "bootstrap"
import "@hotwired/turbo-rails";
import 'channels';
// Probably need to fix it. Does not load
// import '@stimulus_reflex/polyfills'
import "controllers";
import "trix";
import "@rails/actiontext";
import "keyboard-pagination"
import "select2"

// import "chartkick";
// import "Chart.bundle";


console.log("loaded application_admin")

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

  $('[data-confirm]').off("click").click((e) =>{
    const target =  $(e.currentTarget)
    const confirmed = target.attr("data-confirmed");
    const modal =  $('#dataConfirmModal');

    if(!modal[0]) {
      const result = confirm($(target).attr('data-confirm'));
      if (!result) {
        e.stopPropagation()
        e.preventDefault();
      }
      return;
    }

    if ( !confirmed ) {
      e.preventDefault();
      e.stopPropagation();
      modal.find('.modal-body').text($(target).attr('data-confirm'));
      modal.modal("show");
      modal.find(".action-confirm").click((e) => {
        target.attr("data-confirmed", "true");
        target[0].click();
        modal.modal("hide");
      })
    } else {
      target.removeAttr("data-confirmed");
      /* allow default behavior to happen */
    }
  });

  $("input[type='search']").on("search", (e) =>{
    $(e.currentTarget).closest("form").submit();
  })

  $(".filter-data").each((index, filter) => {
    var el = $(filter);
    $(`#${el.data("field")}`).on("change", (e) => {
      Turbo.visit(`${el.data("url")}&${el.data('field')}=${$(e.currentTarget).val()}`);
    })
  })

  $(".form-control.select2:not([data-controller])").select2({
    theme: "bootstrap-5",
  });

  $(".form-select.select2:not([data-controller])").select2({
    theme: "bootstrap-5",
  });

  $(".form-control-sm.select2:not([data-controller])").select2({
    theme: "bootstrap-5",
    containerCssClass: "select2--small", // For Select2 v4.0
    selectionCssClass: "select2--small", // For Select2 v4.1
    dropdownCssClass: "select2--small",
  });

})
