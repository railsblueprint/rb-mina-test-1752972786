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
// import "chartkick";
// import "Chart.bundle";





$(function() {
  var toastElList = [].slice.call(document.querySelectorAll('.toast'))
  var toastList = toastElList.map(function (toastEl) {
    $(toastEl).toast("show");
  })

  $("[data-confirm]").off("click").on("click", (e) => {
    var target = e.currentTarget;
    var result = confirm($(target).data("confirm"));
    if (!result) {
      e.stopPropagation()
      e.preventDefault();
    }
  })

  $("[data-bs-toggle=\"tooltip\"]").tooltip();

  // Needed to enable link inside button
  $(".action-edit-set").click((e) => {
    const target = e.currentTarget;
    Turbo.visit(target.href);
  })

  const backtotop = $(".back-to-top")[0];
  if (backtotop) {
    const toggleBacktotop = () => {
      if (window.scrollY > 100) {
        backtotop.classList.add("active");
      } else {
        backtotop.classList.remove("active");
      }
    };
    window.addEventListener("load", toggleBacktotop);
    $(document).on("scroll", toggleBacktotop)
  }

  $(".alert").alert();

})
