jQuery(function($) {
	$('.paging').html('');
	$('.featured_slider').cycle({ 
		fx:    'fade',
		pager:'.slider_paging',
		pause:         true,
		pauseOnPagerHover: true,
		timeout:	   4000,
		pagerAnchorBuilder: function(idx, slide) {
			var inIdx = idx + 1  ;
		
			/*return '<li id="set1"><a href="#">' + inIdx + '</a></li>';*/
			return '<li><a href="#">'+ inIdx +'</a></li>';
		},
		activePagerClass: 'active'
	});

		
});

