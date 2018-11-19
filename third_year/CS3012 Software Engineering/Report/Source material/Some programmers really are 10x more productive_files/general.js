    jQuery(function () {
      
      jQuery('#main-nav').tinyNav({
        header: 'Navigation' // Writing any title with this option triggers the header
      });
	  
	jQuery(window).scroll(function() {
		if (jQuery(this).scrollTop() > 100) {
			jQuery('header').addClass('reduced');
		} else {
			jQuery('header').removeClass('reduced');
		}
	});

    });	  
