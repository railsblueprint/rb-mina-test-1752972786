class Admin::DesignSystem::IconsController < Admin::Controller
  # rubocop:disable Metrics/MethodLength
  def remix
    @icons =
      {
        Buildings:          %w[ancient-gate ancient-pavilion bank building building-2 building-3 building-4 community
                               government home home-2 home-3 home-4 home-5 home-6 home-7 home-8 home-gear home-heart
                               home-smile home-smile-2 home-wifi hospital hotel store store-2 store-3],
        Business:           %w[advertisement archive
                               archive-drawer at attachment award bar-chart bar-chart-2 bar-chart-box bar-chart-grouped
                               bar-chart-horizontal bookmark bookmark-2 bookmark-3 briefcase briefcase-2 briefcase-3
                               briefcase-4 briefcase-5 bubble-chart calculator calendar calendar-2 calendar-check
                               calendar-event calendar-todo cloud cloud-off copyleft copyright creative-commons
                               creative-commons-by creative-commons-nc creative-commons-nd creative-commons-sa
                               creative-commons-zero customer-service customer-service-2 donut-chart flag flag-2 global
                               honour inbox inbox-archive inbox-unarchive line-chart links mail mail-add mail-check
                               mail-close mail-download mail-forbid mail-lock mail-open mail-send mail-settings
                               mail-star mail-unread mail-volume medal medal-2 pie-chart pie-chart-2 pie-chart-box
                               printer printer-cloud profile projector projector-2 record-mail registered reply
                               reply-all send-plane send-plane-2 service slideshow slideshow-2 slideshow-3 slideshow-4
                               stack trademark window window-2],
        Communication:      %w[chat-1 chat-2 chat-3 chat-4 chat-check chat-delete chat-download chat-follow-up
                               chat-forward chat-heart chat-history chat-new chat-off chat-poll chat-private chat-quote
                               chat-settings chat-smile chat-smile-2 chat-smile-3 chat-upload chat-voice discuss
                               feedback message message-2 message-3 question-answer questionnaire video-chat],
        Design:             %w[anticlockwise anticlockwise-2 artboard artboard-2 ball-pen blur-off brush
                               brush-2 brush-3 brush-4 clockwise clockwise-2 collage compasses compasses-2 contrast
                               contrast-2 contrast-drop contrast-drop-2 crop crop-2 drag-drop drag-move drag-move-2
                               drop edit edit-2 edit-box edit-circle eraser focus focus-2 focus-3 grid hammer ink-bottle
                               input-method layout layout-2 layout-3 layout-4 layout-5 layout-6 layout-bottom
                               layout-bottom-2 layout-column layout-grid layout-left layout-left-2 layout-masonry
                               layout-right layout-right-2 layout-row layout-top layout-top-2 magic mark-pen markup
                               paint paint-brush palette pantone pen-nib pencil pencil-ruler pencil-ruler-2 quill-pen
                               ruler ruler-2 scissors scissors-2 scissors-cut screenshot screenshot-2 shape shape-2 sip
                               slice t-box table table-alt tools],
        Development:        ["braces", "brackets", "bug", "bug-2", "code", "code-box", "code-s",
                             "code-s-slash", "command", "css3", "cursor", "git-branch", "git-commit", "git-merge",
                             "git-pull-request", "git-repository", "git-repository-commits", "git-repository-private",
                             "html5", "parentheses", "terminal", "terminal-box", "terminal-window"],
        Device:             ["airplay", "barcode", "barcode-box", "base-station", "battery", "battery-2",
                             "battery-2-charge", "battery-charge", "battery-low", "battery-saver", "battery-share",
                             "bluetooth", "bluetooth-connect", "cast", "cellphone", "computer", "cpu", "dashboard-2",
                             "dashboard-3", "database", "database-2", "device", "device-recover", "dual-sim-1",
                             "dual-sim-2", "fingerprint", "fingerprint-2", "gamepad", "gps", "gradienter",
                             "hard-drive", "hard-drive-2", "hotspot", "install", "keyboard", "keyboard-box", "mac",
                             "macbook", "mouse", "phone", "phone-find", "phone-lock", "qr-code", "qr-scan",
                             "qr-scan-2", "radar", "remote-control", "remote-control-2", "restart", "rotate-lock",
                             "router", "rss", "save", "save-2", "save-3", "scan", "scan-2", "sd-card", "sd-card-mini",
                             "sensor", "server", "shut-down", "signal-wifi", "signal-wifi-1", "signal-wifi-2",
                             "signal-wifi-3", "signal-wifi-error", "signal-wifi-off", "sim-card", "sim-card-2",
                             "smartphone", "tablet", "tv", "tv-2", "u-disk", "uninstall", "usb", "wifi", "wifi-off",
                             "wireless-charging"],
        Document:           %w[article bill book book-2 book-3 book-mark book-open book-read booklet
                               clipboard contacts-book contacts-book-2 contacts-book-upload draft file file-2 file-3
                               file-4 file-add file-chart file-chart-2 file-cloud file-code file-copy file-copy-2
                               file-damage file-download file-edit file-excel file-excel-2 file-forbid file-gif
                               file-history file-hwp file-info file-list file-list-2 file-list-3 file-lock file-mark
                               file-music file-paper file-paper-2 file-pdf file-ppt file-ppt-2 file-reduce file-search
                               file-settings file-shield file-shield-2 file-shred file-text file-transfer file-unknow
                               file-upload file-user file-warning file-word file-word-2 file-zip folder folder-2
                               folder-3 folder-4 folder-5 folder-add folder-chart folder-chart-2 folder-download
                               folder-forbid folder-history folder-info folder-keyhole folder-lock folder-music
                               folder-open folder-received folder-reduce folder-settings folder-shared folder-shield
                               folder-shield-2 folder-transfer folder-unknow folder-upload folder-user folder-warning
                               folder-zip folders keynote markdown newspaper numbers pages sticky-note sticky-note-2
                               survey task todo],
        Editor:             %w[a-b align-bottom align-center align-justify align-left align-right align-top
                               align-vertically asterisk attachment-2 bold bring-forward bring-to-front code-view
                               delete-column delete-row double-quotes-l double-quotes-r emphasis emphasis-cn
                               english-input flow-chart font-color font-size font-size-2 format-clear functions h-1
                               h-2 h-3 h-4 h-5 h-6 hashtag heading indent-decrease indent-increase input-cursor-move
                               insert-column-left insert-column-right insert-row-bottom insert-row-top italic
                               line-height link link-m link-unlink link-unlink-m list-check list-check-2 list-ordered
                               list-unordered merge-cells-horizontal merge-cells-vertical mind-map node-tree number-0
                               number-1 number-2 number-3 number-4 number-5 number-6 number-7 number-8 number-9 omega
                               organization-chart page-separator paragraph pinyin-input question-mark rounded-corner
                               send-backward send-to-back separator single-quotes-l single-quotes-r sort-asc sort-desc
                               space split-cells-horizontal split-cells-vertical strikethrough strikethrough-2 subscript
                               subscript-2 superscript superscript-2 table-2 text text-direction-l text-direction-r
                               text-spacing text-wrap translate translate-2 underline wubi-input],
        Finance:            %w[24-hours auction bank-card bank-card-2 bit-coin coin coins copper-coin
                               copper-diamond coupon coupon-2 coupon-3 coupon-4 coupon-5 currency exchange exchange-box
                               exchange-cny exchange-dollar exchange-funds funds funds-box gift gift-2 hand-coin
                               hand-heart increase-decrease money-cny-box money-cny-circle money-dollar-box
                               money-dollar-circle money-euro-box money-euro-circle money-pound-box money-pound-circle
                               percent price-tag price-tag-2 price-tag-3 red-packet refund refund-2 safe safe-2
                               secure-payment shopping-bag shopping-bag-2 shopping-bag-3 shopping-basket
                               shopping-basket-2 shopping-cart shopping-cart-2 stock swap swap-box ticket ticket-2
                               trophy vip vip-crown vip-crown-2 vip-diamond wallet wallet-2 wallet-3 water-flash],
        "Health & Medical": %w[capsule dislike dossier empathize first-aid-kit flask hand-sanitizer
                               health-book heart heart-2 heart-3 heart-add heart-pulse hearts infrared-thermometer
                               lungs medicine-bottle mental-health microscope nurse psychotherapy pulse rest-time
                               stethoscope surgical-mask syringe test-tube thermometer virus zzz],
        Logos:              %w[alipay amazon android angularjs app-store apple baidu behance bilibili centos
                               chrome codepen coreos dingding discord disqus douban dribbble drive dropbox edge evernote
                               facebook facebook-box facebook-circle finder firefox flutter gatsby github gitlab google
                               google-play honor-of-kings ie instagram invision kakao-talk line linkedin linkedin-box
                               mastercard mastodon medium messenger microsoft mini-program netease-cloud-music netflix
                               npmjs open-source opera patreon paypal pinterest pixelfed playstation product-hunt qq
                               reactjs reddit remixicon safari skype slack snapchat soundcloud spectrum spotify
                               stack-overflow stackshare steam switch taobao telegram trello tumblr twitch twitter
                               ubuntu unsplash vimeo visa vuejs wechat wechat-2 wechat-pay weibo whatsapp windows xbox
                               xing youtube zcool zhihu],
        Map:                %w[anchor barricade bike bus bus-2 bus-wifi car car-washing caravan charging-pile
                               charging-pile-2 china-railway compass compass-2 compass-3 compass-4 compass-discover cup
                               direction e-bike e-bike-2 earth flight-land flight-takeoff footprint gas-station globe
                               goblet guide hotel-bed lifebuoy luggage-cart luggage-deposit map map-2 map-pin map-pin-2
                               map-pin-3 map-pin-4 map-pin-5 map-pin-add map-pin-range map-pin-time map-pin-user
                               motorbike navigation oil parking parking-box passport pin-distance plane police-car
                               pushpin pushpin-2 restaurant restaurant-2 riding road-map roadster rocket rocket-2 route
                               run sailboat ship ship-2 signal-tower space-ship steering steering-2 subway subway-wifi
                               suitcase suitcase-2 suitcase-3 takeaway taxi taxi-wifi traffic-light train train-wifi
                               treasure-map truck walk],
        Media:              %w[4k album aspect-ratio broadcast camera camera-2 camera-3 camera-lens camera-off
                               camera-switch clapperboard closed-captioning disc dv dvd eject equalizer film fullscreen
                               fullscreen-exit gallery gallery-upload hd headphone hq image image-2 image-add image-edit
                               landscape live mic mic-2 mic-off movie movie-2 music music-2 mv notification
                               notification-2 notification-3 notification-4 notification-off order-play pause
                               pause-circle pause-mini phone-camera picture-in-picture picture-in-picture-2
                               picture-in-picture-exit play play-circle play-list play-list-2 play-list-add play-mini
                               polaroid polaroid-2 radio radio-2 record-circle repeat repeat-2 repeat-one rewind
                               rewind-mini rhythm shuffle skip-back skip-back-mini skip-forward skip-forward-mini
                               sound-module speaker speaker-2 speaker-3 speed speed-mini stop stop-circle stop-mini
                               surround-sound tape video video-add video-download video-upload vidicon vidicon-2
                               voiceprint volume-down volume-mute volume-off-vibrate volume-up volume-vibrate webcam],
        System:             %w[add add-box add-circle alarm alarm-warning alert apps apps-2 arrow-down
                               arrow-down-circle arrow-down-s arrow-drop-down arrow-drop-left arrow-drop-right
                               arrow-drop-up arrow-go-back arrow-go-forward arrow-left arrow-left-circle arrow-left-down
                               arrow-left-right arrow-left-s arrow-left-up arrow-right arrow-right-circle
                               arrow-right-down arrow-right-s arrow-right-up arrow-up arrow-up-circle arrow-up-down
                               arrow-up-s check check-double checkbox checkbox-blank checkbox-blank-circle
                               checkbox-circle checkbox-indeterminate checkbox-multiple checkbox-multiple-blank close
                               close-circle dashboard delete-back delete-back-2 delete-bin delete-bin-2 delete-bin-3
                               delete-bin-4 delete-bin-5 delete-bin-6 delete-bin-7 divide download download-2
                               download-cloud download-cloud-2 error-warning external-link eye eye-2 eye-close eye-off
                               filter filter-2 filter-3 filter-off find-replace forbid forbid-2 function history
                               indeterminate-circle information list-settings loader loader-2 loader-3 loader-4 l
                               oader-5 lock lock-2 lock-password lock-unlock login-box login-circle logout-box
                               logout-box-r logout-circle logout-circle-r menu menu-2 menu-3 menu-4 menu-5 menu-add
                               menu-fold more more-2 notification-badge question radio-button refresh search search-2
                               search-eye settings settings-2 settings-3 settings-4 settings-5 settings-6 share
                               share-box share-circle share-forward share-forward-2 share-forward-box shield
                               shield-check shield-cross shield-flash shield-keyhole shield-star shield-user side-bar
                               spam spam-2 spam-3 star star-half star-half-s star-s subtract thumb-down thumb-up time
                               timer timer-2 timer-flash toggle upload upload-2 upload-cloud upload-cloud-2 zoom-in
                               zoom-out],
        "User&Faces":       %w[account-box account-circle account-pin-box account-pin-circle admin aliens
                               bear-smile body-scan contacts criminal emotion emotion-2 emotion-happy emotion-laugh
                               emotion-normal emotion-sad emotion-unhappy genderless ghost ghost-2 ghost-smile group
                               group-2 men mickey open-arm parent robot skull skull-2 spy star-smile team travesti
                               user user-2 user-3 user-4 user-5 user-6 user-add user-follow user-heart user-location
                               user-received user-received-2 user-search user-settings user-shared user-shared-2
                               user-smile user-star user-unfollow user-voice women],
        Weather:            %w[blaze celsius cloud-windy cloudy cloudy-2 drizzle earthquake fahrenheit fire
                               flashlight flood foggy hail haze haze-2 heavy-showers meteor mist moon moon-clear
                               moon-cloudy moon-foggy rainbow rainy showers snowy sun sun-cloudy sun-foggy temp-cold
                               temp-hot thunderstorms tornado typhoon windy],
        Others:             %w[basketball bell billiards boxing cactus cake cake-2 cake-3 character-recognition
                               door door-closed door-lock door-lock-box door-open football fridge game handbag key
                               key-2 knife knife-blood leaf lightbulb lightbulb-flash outlet outlet-2 ping-pong plant
                               plug plug-2 recycle reserved scales scales-2 scales-3 seedling shirt sword t-shirt
                               t-shirt-2 t-shirt-air umbrella voice-recognition wheelchair]
      }
  end
  # rubocop:enable Metrics/MethodLength
end
