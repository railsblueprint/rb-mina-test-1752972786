import { Controller } from "@hotwired/stimulus";
import Cropper from "cropperjs";

export default class extends Controller {
  static targets = ["source", "cropped", "settings", "remove", "upload", "dropzone"];

  connect() {
    console.log("Image loaded");
    $(this.dropzoneTarget).on("dragover", (e) =>  {
      e.preventDefault();
      e.stopPropagation();
      this.dropzoneTarget.classList.add("drag-over")
    }).on("dragleave", () => this.dropzoneTarget.classList.remove("drag-over"))
        .on("drop", (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.uploadTarget.files = e.originalEvent.dataTransfer.files;
          this.dropzoneTarget.classList.remove("drag-over")
          // this.uploadTarget.change();
          this.uploadChanged(e.originalEvent.dataTransfer.files[0]);
        });


    this.createCropper();
  }

  createCropper() {
    var cropperData;
    try {
      cropperData = JSON.parse(this.settingsTarget.value);
    } catch (error) {
      cropperData = {};
    }


    const cropperOptions = {
      aspectRatio: 1,
      viewMode: 2, // Crop within the container
      minCropBoxWidth: 100,
      minCropBoxHeight: 100,
      movable: false,
      zoomable: false,
      data: cropperData,
      ready: () => {
        this.adjustOutputSize();
      },
      crop: () => {
        this.updateSettings();
      },
    };

    const image = this.sourceTarget;
    this.cropper = new Cropper(image, cropperOptions);
    console.log(this.cropper)
  }

  change(e) {
    e.preventDefault();
    e.stopPropagation();
    const file = e.currentTarget.files[0];
    this.uploadChanged(file);
  }

  uploadChanged(file) {
    if (/^image\/\w+/.test(file.type)) {
      this.uploadedImageType = file.type;
      this.uploadedImageName = file.name;

      if (this.uploadedImageURL) {
        URL.revokeObjectURL(this.uploadedImageURL);
      }

      if (this.cropper) {
        this.cropper.destroy();
      }

      this.sourceTarget.src = this.uploadedImageURL = URL.createObjectURL(file);
      this.settingsTarget.value="";

      this.createCropper();

      $(".avatar-editor-actions").removeClass("d-none");
      $(".avatar-editor-placeholder").addClass("d-none");
      this.removeTarget.value = "false";

    } else {
      window.alert('Please choose an image file.');
    }
  }

  upload(e) {
    e.preventDefault();
    e.stopPropagation();
    console.log("Upload");
    this.uploadTarget.click();
  }

  remove(e) {
    e.preventDefault();
    e.stopPropagation();

    this.removeTarget.value = "true";
    if (this.cropper) {
      this.cropper.destroy();
    }
    $(".avatar-editor-actions").addClass("d-none");
    $(".avatar-editor-placeholder").removeClass("d-none");
    this.sourceTarget.src=""

  }

  updateSettings() {
    const cropData = this.cropper.getData();
    this.settingsTarget.value = JSON.stringify(cropData);

    const canvas = this.cropper.getCroppedCanvas();
    this.croppedTarget.value = canvas.toDataURL();
  }
}
