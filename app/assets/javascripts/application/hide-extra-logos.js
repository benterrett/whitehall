(function($) {
  var $organisations = $('.js-hide-extra-logos .organisations-icon-list'),
      $organisation = $organisations.find('.organisation'),
      all = $organisation.length,
      hidden = 0,
      $toggle;

  if($organisations.height() > $organisation.outerHeight(true)){
    $toggle = $('<li class="show-other-content"><a href="#" title="Show additional links">+ others</a></li>');
    $organisations.append($toggle);
    while(($organisations.height() > $organisation.outerHeight(true)) && (all - hidden > 1)){
      hidden = hidden + 1;
      $($organisation.get(all-hidden)).hide();
    }

    $toggle.on('click', function(e) {
      e.preventDefault();
      $toggle.remove();
      $organisation.filter(':hidden').show().focus();
    });
    $organisations.attr('aria-live', 'polite');
  }
}(jQuery));