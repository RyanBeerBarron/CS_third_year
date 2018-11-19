/*
Last updated 2018-03-29 by AJ Sedlak
replaced link to elqCfg.min.js with Eloqua domain and relative protocol so that HTTPS will work
*/

//Eloqua Tracking
var _elqQ = _elqQ || [];
_elqQ.push(['elqSetSiteId', '1078']);
_elqQ.push(['elqTrackPageView']);
//_elqQ.push(['elqGetCustomerGUID']);
(function () {
function async_load() {
var s = document.createElement('script'); s.type = 'text/javascript';
s.async = true; s.src = '//img.en25.com/i/elqCfg.min.js';
var x = document.getElementsByTagName('script')[0]; x.parentNode.insertBefore(s, x);
}
if (window.addEventListener) window.addEventListener('DOMContentLoaded', async_load, false);
else if (window.attachEvent) window.attachEvent('onload', async_load);
})();

//Additional Tracking Functions
function elqTrackPage(URL, referrer) {
    _elqQ.push(['elqTrackPageView', URL, referrer]);
}

function getCookiesMap(cookiesString) {
    return cookiesString.split(";")
        .map(function(cookieString) {
            return cookieString.trim().split("=");
        })
        .reduce(function(acc, curr) {
            acc[curr[0]] = curr[1];
            return acc;
        }, {});
}

//get parameters of this page
var vars = [], hash;
var hashes = window.location.search.replace('?','').split('&');
for(var i=0;i<hashes.length;i++) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
}

//YouTube iframe tracking - overrides some functions of Plugin: YouTube plugin SC14.9/15 v1.4
/*
function WaitForSCYT() {
    if (!$.isFunction(s_YTp)) {
        setTimeout(WaitForSCYT, 100);
        return;
    }
    var ytIframePlayerList = $('iframe[src*="youtube.com/embed"]');
    var YTIframeIDs = [];
    if (ytIframePlayerList.length > 0) { $.getScript('//www.youtube.com/iframe_api',function(){
        for(var i = 0;i < ytIframePlayerList.length; i++) {
            ytIframeVideoID = ytIframePlayerList[i].src.substring(ytIframePlayerList[i].src.lastIndexOf('/') + 1,ytIframePlayerList[i].src.lastIndexOf('?'));
            ytIframePlayerList[i].id = ytIframeVideoID;
            YTIframeIDs[i] = ytIframeVideoID;
            
            s_YTO.v[ytIframeVideoID].vg = function (yp) {
                try {
                    var t = this,F = 'function',O = 'object',N = 'number',S = 'string',u = '',x = u,y = u,pt = typeof yp;
                    if (pt == O || pt == F) {
                        if (typeof yp.getVideoUrl == F) u = yp.getVideoUrl();
                        if (typeof yp.getVideoData == F) {
                            x = yp.getVideoData();
                            if (typeof x == O) {
                                if (typeof x.video_id == S) y = x.video_id;
                                if (typeof x.title == S) s.st = x.title
                            }
                        }
                        if (!y && u) y = s_YTgk(u);
                        t.sv = 'YouTube';
                        t.sv += '|' + (y ? y : t.id);
                        if (t.st) t.sv += '|' + t.st;
                        if ((typeof yp.getPlayerState) == F) {
                            x = yp.getPlayerState();
                            if (typeof x == N) {
                                if (x === 1) elqTrackPage('http://www.youtube.com/watch?v=' + t.id, '');
                                t.ys = x
                            }
                        }
                        t.qs = 0;
                        if ((typeof yp.getCurrentTime) == F) {x = yp.getCurrentTime();t.qs = (typeof x == N) ? Math.round(x) : 0}
                        t.ts = 0;
                        if ((typeof yp.getDuration) == F) {x = yp.getDuration();t.ts = (typeof x == N) ? Math.round(x) : 0}
                    }
                } catch (e) {}
            };
            
        }
    }); }
}

$(function(){ WaitForSCYT(); });
*/
//end YouTube tracking

(function($) {
	$(function(){
		
		//Remove embargoed countries from forms
		var embargoedCountries = ['Cuba','Iran, Islamic Republic of','Sudan','Syrian Arab Republic','Korea, Democratic People\'s Republic of'];
		for (var ECi = 0; ECi < embargoedCountries.length; ECi++) {
            $('option[value="' + embargoedCountries[ECi] + '"]').each(function(){ $(this).remove(); }); }

		//register autoplayed videos in Eloqua
		if (typeof(vars.playVideo) !== 'undefined' && vars.playVideo !== '' && vars.playVideo !== null) {
			var linkToTrack = 'http://' + window.location.host + '/playVideo/' + vars.playVideo;
			elqTrackPage(linkToTrack, '');
		}

//track outbound links in Eloqua
		//File extensions
		var extensionsToTrack = ['pdf','png','mp3','mp4','jpg'];
		$.each(extensionsToTrack,function(extIndex,extVal){
			$('body').on('click','a[href$=".' + extVal + '"]', function () {
				elqTrackPage(this.href, '');
			});
		});
		//External URL fragments
		//YOUTUBE = youtube, youtu.be
		//ON24  = on24
		//BRIGHTCOVE = brightcove, bcove
		//PUBLIC SECTOR VIEW = publicsectorview
		var serversToTrack = ['youtube','youtu.be','on24','brightcove','bcove','publicsectorview','theworkspacetoday'];
		$.each(serversToTrack,function(urlIndex,urlVal){
			$('body').on('click','a[href*="' + urlVal + '"]', function () {
				elqTrackPage(this.href, '');
			});
		});
		//track clicks on brightcove lightbox
		$('body').on('click','a[onClick*="playBrightcoveLightbox"]', function () {
			var originalOnClick = $(this).attr('onClick');
			var scriptMatch = originalOnClick.match(/playBrightcoveLightbox\('(.*)'[\s,]*'\d*'[\s,]*'\d*'[\s,]*'.*'[\s,]*'\d*'[\s,]*'[\S]*'\)/);
			if (scriptMatch[1] !== null && scriptMatch[1] !== '') {
				var linkToTrack = 'http://' + window.location.host + '/playVideo/' + scriptMatch[1];
				elqTrackPage(linkToTrack, '');
			}
		});
        
		//track modal or other non-URL clicks
        $('a[data-elqtrack]').addClass('elqtrack');
		$('body').on('click','a.elqtrack', function() {
		    var linkToTrack = $(this).attr('data-elqtrack');
            if (linkToTrack) { elqTrackPage(linkToTrack, ''); }
		});
        
//get UTM values from query string and store in cookie
        var trackingExpiration = 1, //value in days
            trackingParameters = ['utm_campaign','utm_content','utm_medium','utm_source','utm_term'],
            host = window.location.host,
            domain,
            expires = '',
            trackingValues = {},
            //get current cookies
            cookies = getCookiesMap(document.cookie),
            futureTime = new Date(),
            expiredTime = new Date(),
            srcMapped = ['email','esig','li','psview','sales','social','wst','web','website'];
        
        //expiration for new cookies
        futureTime.setTime(futureTime.getTime() + (trackingExpiration * 24 * 60 * 60 * 1000));
        futureTime.toUTCString();
        
        //expiration in past for cookie removal
        expiredTime.setTime(expiredTime.getTime() - (24 * 60 * 60 * 1000));
        expiredTime.toUTCString();
        
        //if host NOT polycom.com or subdomains or has suffixes after "polycom.com"
        if (host.indexOf('polycom.com') === -1 || host.indexOf('polycom.com') !== (host.length - 11)) {
            domain = ';domain=' + host.replace('www.','').replace('response.','').replace('author.','').replace(':4502','').replace('ppnqa.','').replace(':5502','').replace(':5503','');
        //for polycom.com and all subdomains
        } else if (host.indexOf('polycom.com') !== -1) {
            domain = ';domain=.polycom.com';
        }
                
        //copy query string parameters to object for evaluation
        for (var p=0;p<trackingParameters.length;p++) {
            if (typeof(vars[trackingParameters[p]]) !== 'undefined' && vars[trackingParameters[p]] !== '' && vars[trackingParameters[p]] !== null) {
                trackingValues[trackingParameters[p]] = decodeURIComponent(vars[trackingParameters[p]]);
            } else if (trackingParameters[p] === 'utm_campaign' && typeof(vars.cn) !== 'undefined' && vars.cn !== '' && vars.cn !== null) {
                trackingValues.utm_campaign = vars.cn;
            }
        }
        
        //if at least one parameter specified
        if (Object.keys(trackingValues).length > 0) {
            for (var v=0;v<trackingParameters.length;v++) {
                if (trackingValues[trackingParameters[v]]) {
                    //copy parameter values to cookies
                    document.cookie = trackingParameters[v] + '=' + trackingValues[trackingParameters[v]] + ';expires=' + futureTime + domain + ';path=/';
                } else {
                    //delete current cookie value
                    document.cookie = trackingParameters[v] + '=;expires=' + expiredTime + domain + ';path=/';
                }
            }
        } else if (!cookies.utm_medium && !cookies.utm_source) {
            //set default medium and source if no parameters present and no existing cookie
            document.cookie = 'utm_medium=direct' + expires + domain + ';path=/';
            document.cookie = 'utm_source=direct' + expires + domain + ';path=/';
        }
        
        //map legacy src values
        if ((!cookies.utm_medium || cookies.utm_medium === 'direct') && (!cookies.utm_source || cookies.utm_source === 'direct') && vars.src && $.inArray(vars.src,srcMapped) > -1) {
            if (vars.src === 'email') {
                document.cookie = 'utm_medium=email' + expires + domain + ';path=/';
                document.cookie = 'utm_source=elq-campaign' + expires + domain + ';path=/';
            } else if (vars.src === 'esig') {
                document.cookie = 'utm_medium=email-signature' + expires + domain + ';path=/';
                document.cookie = 'utm_source=email-signature' + expires + domain + ';path=/';
            } else if (vars.src === 'li') {
                document.cookie = 'utm_medium=social-paid' + expires + domain + ';path=/';
                document.cookie = 'utm_source=linkedin' + expires + domain + ';path=/';
            } else if (vars.src === 'psview') {
                document.cookie = 'utm_medium=co' + expires + domain + ';path=/';
                document.cookie = 'utm_source=psview' + expires + domain + ';path=/';
            } else if (vars.src === 'sales') {
                document.cookie = 'utm_medium=email' + expires + domain + ';path=/';
                document.cookie = 'utm_source=outlook-sales' + expires + domain + ';path=/';
            } else if (vars.src === 'social') {
                document.cookie = 'utm_medium=social' + expires + domain + ';path=/';
                document.cookie = 'utm_source=social' + expires + domain + ';path=/';
            } else if (vars.src === 'wst') {
                document.cookie = 'utm_medium=co' + expires + domain + ';path=/';
                document.cookie = 'utm_source=psview' + expires + domain + ';path=/';
            } else {
                document.cookie = 'utm_medium=direct' + expires + domain + ';path=/';
                document.cookie = 'utm_source=direct' + expires + domain + ';path=/';
            }
        }
        
	});
})(jQuery);