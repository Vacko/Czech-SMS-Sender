var Gatekeeper = {
	maxRecipients: 1,
	maxLength: 160,
	maxSubjectLength: 80,
	maxSize: 280000,
	maxAttachments: 3,
	language: 'cs',

	maxWidth: 105,
	maxHeight: 105,

	maxTemplates: 15,

	sessionTimeout: 300000,
	logoutTimeout: 60000,
	autoLogoutTick: 200,

	attachments: [],

	delay: 0,
	sendLock: 0,
	
	undoStack: [],

	message: {
		cs: {
			add: 'Nahraj přílohu',
			adding: 'Nahrávám přílohu...',
			attremove: 'Odstranit',
			confirmMmsHistoryWipe: 'Opravdu chcete smazat celou MMS historii?',
			confirmSmsHistoryWipe: 'Opravdu chcete smazat celou SMS historii?',
			confirmTemplatesWipe: 'Opravdu chcete smazat všechny šablony?',
			contacts: 'Kontakty: ',
			delayEnforced: 'Další zprávu je možné odeslat nejdříve za 30 vteřin po odeslání předchozí zprávy.',
			from: ' z ',
			login: 'Přihlásit',
			uploadEmpty: 'Vložena prázdná příloha',
			uploadError: 'Chyba při vkládání přílohy: ',
			uploadFull: 'Již je přiložen maximální počet příloh',
			uploadNotSupported: 'Nepodporovaný druh přílohy',
			uploadOk: 'Příloha vložena v pořádku.',
			failure: {
				addressbook: 'Načítání adresáře se nezdařilo.',
				attremove: 'Odstranění přílohy se nezdařilo.',
				deleteMMS: 'Smazání MMS zprávy se nezdařilo.',
				deleteSMS: 'Smazání SMS zprávy se nezdařilo.',
				deleteTemplate: 'Smazání šablony se nezdařilo.',
				favorite: 'Načítání nejčastějších čísel se nezdařilo.',
				history: 'Načítání historie se nezdařilo.',
				isTMCZ: 'Ověřování, jestli je číslo v síti T-Mobile se nezdařilo.',
				saveMmsAsTemplate: 'Uložení MMS zprávy do šablon se nezdařilo',
				saveSmsAsTemplate: 'Uložení SMS zprávy do šablon se nezdařilo',
				saveTemplate: 'Uložení šablony se nezdařilo',
				store: 'Uložení rozpracované zprávy se nezdařilo.',
				template: 'Načítání šablon se nezdařilo.',
				upload: 'Nahrávání souboru se nezdařilo.',
				useAttachment: 'Připojení přílohy z historie se nezdařilo',
				wipeMMS: 'Vymazání historie MMS zpráv se nezdařilo',
				wipeSMS: 'Vymazání historie SMS zpráv se nezdařilo',
				wipeTemplates: 'Vymazání šabon se nezdařilo'
			},
			error: {
				attachmentTooBig: 'Příloha je příliš velká.',
				badRecipient: 'Telefonní číslo není platné.',
				nonTMCZ: 'Příjemce není ze sítě TMCZ',
				noSpam: 'Příjemce si nepřeje přijímat zprávy z veřejné SMS brány.',
				templatetoolong: 'Příliš dlouhý text!',
				toolong: 'Příliš dlouhý text!',
				tooMany: 'Příliš mnoho příjemců!'
			}
		},
		en: {
			add: 'Upload attachment',
			adding: 'Uploading attachment',
			attremove: 'Remove',
			confirmMmsHistoryWipe: 'Are you sure you want to delete all MMS history?',
			confirmSmsHistoryWipe: 'Are you sure you want to delete all SMS history?',
			confirmTemplatesWipe: 'Are you sure you want to delete all templates?',
			contacts: 'Contacts: ',
			delayEnforced: 'Wait 30 seconds before the next message can be send.',
			from: ' from ',
			login: 'Login',
			uploadEmpty: 'An empty attachment was uploaded.',
			uploadError: 'Attachment failure: ',
			uploadFull: 'Maximum number of attachments already added.',
			uploadNotSupported: 'Unsupported type of attachment.',
			uploadOk: 'Attachment correctly uploaded.',
			failure: {
				addressbook: 'Address book load failure.',
				attremove: 'Attachment removal failure.',
				deleteMMS: 'MMS removal failure.',
				deleteSMS: 'SMS removal failure.',
				deleteTemplate: 'Template removal failure.',
				favorite: 'Most common recipients load failure.',
				history: 'History load failure.',
				isTMCZ: 'T-Mobile number test failure.',
				saveMmsAsTemplate: 'Saving MMS as a template failure.',
				saveSmsAsTemplate: 'Saving SMS as a template failure.',
				saveTemplate: 'Template saving failure.',
				store: 'Unfinished message storage failure.',
				template: 'Templates upload failure.',
				upload: 'File upload failure.',
				useAttachment: 'Adding an attachment from history failure.',
				wipeMMS: 'MMS history removal failure.',
				wipeSMS: 'SMS history removal failure.',
				wipeTemplates: 'Templates removal failure.'
			},
			error: {
				attachmentTooBig: 'The attachment is too big.',
				badRecipient: 'Wrong phone number!',
				nonTMCZ: 'Recipient is not a T-Mobile network member.',
				noSpam: 'The recipient does not wish to receive messages send from open SMS gateway.',
				templatetoolong: 'The text is too long!',
				toolong: 'Message is too long!',
				tooMany: 'Too many recipients!'
			}
		}
	},

	mnl: [0,  1, 154, 307, 460, 613],
	mnh: [1,161, 307, 460, 613, 766],

	expire: null,
	expireLogout: null,
	autoLogoutIn: 60000,

	delayedCheck: null,

	localize: function (message) {
		try {
			return this.message[this.language][message] ? this.message[this.language][message] : '???'+message+'???';
		} catch (e) {
			return '???'+message+'???';
		}
	},
	localizeError: function (error) {
		try {
			return this.message[this.language].error[error] ? this.message[this.language].error[error] : '???ERROR '+error+'???';
		} catch (e) {
			return '???ERROR '+error+'???';
		}
	},
	localizeFailure: function (failure) {
		try {
			return this.message[this.language].failure[failure] ? this.message[this.language].failure[failure] : '???FAILURE '+failure+'???';
		} catch (e) {
			return '???FAILURE '+failure+'???';
		}
	},

	scrollIntoView: function(e) {
		e = $(e);
		if (e.scrollIntoView) {
			try {
				e.scrollIntoView();
			} catch (exc) {}
			$('p').scrollLeft = 0;
		}
	},
	blockSend: function () {
		if (!$('send')) return;
		Gatekeeper.sendLock++;
		$('send').disable();
	},
	unblockSend: function (num) {
		if (!$('send')) return;
		if (num) Gatekeeper.sendLock -= num;
		else Gatekeeper.sendLock--;
		if (Gatekeeper.sendLock < 0) Gatekeeper.sendLock = 0;
		if (Gatekeeper.sendLock == 0) {
			$('send').enable();
			$('send').title = '';
		}
	},

	failure: function (failure) {
		var div = $('gt-errormessage');
		div.getElementsBySelector('ul.info')[0].update(
			'<li><span>'
			+ Gatekeeper.localizeFailure(failure)
			+ '</span></li>');
		div.show();
		Gatekeeper.scrollIntoView(div);
	},

	addError: function (id, error) {
		var element = $(id+'-errors');
		if (element) {
			Gatekeeper.blockSend();
			element.insert('<li><span>'+Gatekeeper.localizeError(error)+'</span></li>');
		}
		$(id).addClassName('error');
	},
	
	clearErrors: function (id) {
		var element = $(id+'-errors');
		if(element && element.innerHTML.length > 0) {
			Gatekeeper.unblockSend(element.select('li').length);
			element.update();
		}
		$(id).removeClassName('error');
	},

	autoLogout: function () {
		if (Gatekeeper.autoLogoutIn <= 0) {
			Gatekeeper.cancelAutoLogout();
			window.location = 'timeout.jsp';
		} else {
			Gatekeeper.autoLogoutIn -= Gatekeeper.autoLogoutTick;
			var gauge = $('autologoutgauge');
			if (gauge) gauge.style.width = ((100*Gatekeeper.autoLogoutIn) / Gatekeeper.logoutTimeout) + '%';
		}
	},
	cancelAutoLogout: function () {
		if (Gatekeeper.expireLogout) {
			window.clearInterval(Gatekeeper.expireLogout);
			Gatekeeper.expireLogout = null;
		}
	},
	hit: function () {
		Gatekeeper.cancelAutoLogout();
		if (Gatekeeper.expire) window.clearTimeout(Gatekeeper.expire);
		Gatekeeper.expire = window.setTimeout(function () {
			var msg = $('gt-message');
			if (msg) {
				var gauge = $('autologoutgauge');
				if (gauge) gauge.style.width = ((100*Gatekeeper.autoLogoutIn) / Gatekeeper.logoutTimeout) + '%';
				msg.show();
				Gatekeeper.scrollIntoView(msg);
				Gatekeeper.autoLogoutIn = Gatekeeper.logoutTimeout;
				Gatekeeper.expireLogout = window.setInterval(Gatekeeper.autoLogout, Gatekeeper.autoLogoutTick);
			}
		}, Gatekeeper.sessionTimeout);
	},
	moreTime: function (event) {
		Gatekeeper.cancelAutoLogout();
		event.stop();
		new Ajax.Request('open/ajax/dummy', {
			method: 'get',
			onFailure: function (transport) {
				failure('moreTime');
			}
		});
		Gatekeeper.hit();
	},

	delayCheck: function (event, func, delay) {
		if (Gatekeeper.delayedCheck) window.clearTimeout(Gatekeeper.delayedCheck);
		Gatekeeper.delayedCheck = window.setTimeout(function() {
			Gatekeeper.delayedCheck = null;
			func(null);
		}, delay);
	},
	checkIsTMCZ: function (event) {
		new Ajax.Request('closed/ajax/msisdn', {
			method: 'get',
			parameters: {
				msisdn: $F('recipients').replace(/"[^\"]*"[^<]+<([0-9]+)>/g, '$1'),
				limit: Gatekeeper.maxRecipients
			},
			onSuccess: function (transport) {
				Gatekeeper.clearErrors('recipients');
				if (transport.responseJSON.bad)		Gatekeeper.addError('recipients', 'badRecipient');
				if (transport.responseJSON.nonTMCZ)	$('recipients').addClassName('notmobile');
				else								$('recipients').removeClassName('notmobile');
				if (transport.responseJSON.many)	Gatekeeper.addError('recipients', 'tooMany');
			},
			onFailure: function (transport) {
				Gatekeeper.failure('isTMCZ');
			}
		});
		Gatekeeper.hit();
	},

	applyTemplate: function (event, text) {
		if (event) event.stop();
		$('text').value = text;
		$('gt-history').update();
		$('text').focus();
		Gatekeeper.scrollIntoView('text');
	},
	loadTemplates: function (event, i) {
		if (event) event.stop();
		new Ajax.Updater(
			{
				success: 'gt-history'
			},
			'closed/ajax/templates.jsp?pos='+((i-1)*5)+'&count=5',
			{
				evalScripts: true,
				onFailure: function(transport) {
					Gatekeeper.failure('template');
				},
				onSuccess: function(transport) {
					Gatekeeper.scrollIntoView('gt-history');
				}
			}
		);
		Gatekeeper.hit();
	},
	wipeTemplates: function (event) {
		if (event) event.stop();
		if (confirm(Gatekeeper.localize('confirmTemplatesWipe'))) {
			new Ajax.Request('closed/ajax/wipe-templates', {
				onSuccess: function (transport) {
					$('gt-history').update();
				},
				onFailure: function (transport) {
					Gatekeeper.failure('wipeTemplates');
				}
			});
			Gatekeeper.hit();
		}
	},
	loadSystemTemplates: function (event, i) {
		if (event) event.stop();
		new Ajax.Updater(
			{
				success: 'gt-history'
			},
			'open/ajax/templates.jsp?pos='+((i-1)*5)+'&count=5',
			{
				evalScripts: true,
				onFailure: function(transport) {
					Gatekeeper.failure('template');
				},
				onSuccess: function(transport) {
					Gatekeeper.scrollIntoView('gt-history');
				}
			}
		);
		Gatekeeper.hit();
	},

	loadSMSHistory: function (event, i, sort) {
		if (event) event.stop();
		if (!sort) sort = 'd';
		new Ajax.Updater(
			{
				success: 'gt-history'
			},
			'closed/ajax/smshistory.jsp?pos='+((i-1)*5)+'&count=5&sort='+sort,
			{
				evalScripts: true,
				onFailure: function(transport) {
					Gatekeeper.failure('history');
				},
				onSuccess: function(transport) {
					Gatekeeper.scrollIntoView('gt-history');
				}
			}
		);
		Gatekeeper.hit();
	},
	deleteSMSHistory: function (event, i, page, sort) {
		if (event) event.stop();
		new Ajax.Request('closed/ajax/delete-sms?id='+i, {
			onSuccess: function (transport) {
				Gatekeeper.loadSMSHistory(null, page, sort);
			},
			onFailure: function (transport) {
				Gatekeeper.failure('deleteSMS');
			}
		});
		Gatekeeper.hit();
	},
	wipeSMSHistory: function (event) {
		if (event) event.stop();
		if (confirm(Gatekeeper.localize('confirmSmsHistoryWipe'))) {
			new Ajax.Request('closed/ajax/wipe-sms', {
				onSuccess: function (transport) {
					$('gt-history').update();
				},
				onFailure: function (transport) {
					Gatekeeper.failure('wipeSMS');
				}
			});
			Gatekeeper.hit();
		}
	},
	loadMMSHistory: function (event, i, sort) {
		if (event) event.stop();
		if (!sort) sort = 'd';
		new Ajax.Updater(
			{
				success: 'gt-history'
			},
			'closed/ajax/mmshistory.jsp?pos='+((i-1)*5)+'&count=5&sort='+sort,
			{
				evalScripts: true,
				onFailure: function(transport) {
					Gatekeeper.failure('history');
				},
				onSuccess: function(transport) {
					Gatekeeper.scrollIntoView('gt-history');
				}
			}
		);
		Gatekeeper.hit();
	},
	deleteMMSHistory: function (event, i, page, sort) {
		if (event) event.stop();
		new Ajax.Request('closed/ajax/delete-mms?id='+i, {
			onSuccess: function (transport) {
				Gatekeeper.loadMMSHistory(null, page, sort);
			},
			onFailure: function (transport) {
				Gatekeeper.failure('deleteMMS');
			}
		});
		Gatekeeper.hit();
	},
	wipeMMSHistory: function (event) {
		event.stop();
		if (confirm(Gatekeeper.localize('confirmMmsHistoryWipe'))) {
			new Ajax.Request('closed/ajax/wipe-mms', {
				onSuccess: function (transport) {
					$('gt-history').update();
				},
				onFailure: function (transport) {
					Gatekeeper.failure('wipeMMS');
				}
			});
			Gatekeeper.hit();
		}
	},
	toggleFullSize: function (event, elem) {
		event.stop();
		var fullsize = $('gt-fullsize');
		if (fullsize) {
			fullsize.parentNode.removeChild(fullsize);
		} else {
			fullsize = new Element('img', {
				id: 'gt-fullsize',
				src: elem.src,
				style: 'position:absolute;left:0px;top:0px;z-index:1000;'
			});
			$('gt-detail').appendChild(fullsize);
			fullsize.observe('click', Gatekeeper.toggleFullSize.bindAsEventListener(this));
		}
	},

	totalSize: function () {
		var total = 0;
		for (var i in this.attachments) {
			var j = new Number(i);
			if (!isNaN(j)) {
				if (this.attachments[j] != undefined) {
					total += this.attachments[j].size;
				}
			}
		}
		return total;
	},
	updateGauge: function () {
		var total = Gatekeeper.totalSize();
		var pct = (100 * total / Gatekeeper.maxSize);
		if (pct <= 100) {
			$('gauge').style.width = pct + '%';
			$('gauge').removeClassName('over');
			Gatekeeper.unblockSend();
			var free = Math.floor((Gatekeeper.maxSize-total)/1000);
			total = Math.ceil(total / 1000);
			$('size-total').update(total);
			$('size-free').update(free);
		} else {
			$('gauge').style.width = '100%';
			$('gauge').addClassName('over');
			Gatekeeper.blockSend();
			total = Math.ceil(total / 1000);
			$('size-total').update(total);
			$('size-free').update(0);
		}
	},

	paste: function (text) {
		$('text').value += text;
	},
	compressMessage: function (event) {
		event.stop();
		Gatekeeper.undoStack.push($F('text'));
		var dia = "áäčďéěíĺľňóôőöŕšťúůűüýřžÁÄČĎÉĚÍĹĽŇÓÔŐÖŔŠŤÚŮŰÜÝŘŽ";
		var sub = "aacdeeillnoooorstuuuuyrzAACDEEILLNOOOORSTUUUUYRZ";
		var t = $F('text');
		var r = '';
		for (var i = 0; i<t.length; i++) {
			if (dia.indexOf(t.charAt(i)) != -1) {
				r += sub.charAt(dia.indexOf(t.charAt(i)));
			} else {
				r += t.charAt(i);
			}
		}
		t = r.toLowerCase();
		r = '';
		var upper = true;
		for (var i = 0; i<t.length; i++) {
			if (t.charAt(i) == ' ' || t.charAt(i) == '\r' || t.charAt(i) == '\n') {
				upper = true;
			} else {
				if (upper) {
					r += t.charAt(i).toUpperCase();
					upper = false;
				} else {
					r += t.charAt(i);
				}
			}
		}
		$('text').value = r;
	},
	undoMessage: function (event) {
		event.stop();
		if (Gatekeeper.undoStack.length > 0) {
			$('text').value = Gatekeeper.undoStack.pop();
		}
	},

	addRecipient: function (event, element) {
	  	event.stop();
	    var r = element.innerHTML;
	    r = r.replace(/<strong>(.*)<\/strong> ([^&]*)/ig, '"$1 $2" ').replace(/&lt;/g, '<').replace(/&gt;/g, '>');
	    var rcpts = $F('recipients').replace (/, *$/, '');
		if (/^ *$/.test(rcpts))	rcpts = r;
		else					rcpts += ', '+r;
	  	$('recipients').value = rcpts;
	  	this.checkIsTMCZ(event);
	},

	hideSmileysHandler: null,
	showSmileys: function (event) {
		if (event) event.stop();
		var div = $('presmajlici');
		if(div) {
			div.show();
			$$('#p, #p a, #p input').each(function(e){e.observe('click', Gatekeeper.hideSmileysHandler, true);});
		}
		div = $('gt-help');
		if (div) div.hide();
	},
	hideSmileys: function (event) {
		var div = $('presmajlici');
		if (div) {
			div.hide();
			$$('#p, #p a, #p input').each(function(e){e.stopObserving('click', Gatekeeper.hideSmileysHandler, true);});
		}
	},
	addSmiley: function (event, element) {
		if (event) event.stop();
		this.hideSmileys(event);
		this.paste(element.title);
	},

	initPosition: function() {
	},
	countCharactersLock: false,
	countCharacters: function() {
		if (!$('text')) return;
		if (!Gatekeeper.countCharactersLock) {
			try {
				Gatekeeper.countCharactersLock = true;
				var text = $F('text');
				var l = text.length;
				if (l > Gatekeeper.maxLength) {
					alert(Gatekeeper.localizeError('toolong'));
					text = text.substring(0, Gatekeeper.maxLength);
					$('text').value = text;
					l = Gatekeeper.maxLength;
				}
				var ctr_used = $('cntr2');
				var ctr_rem = $('cntr1');
				ctr_used.value = l;
				ctr_rem.value = (Gatekeeper.maxLength - l);

				var ctr_messages = $('cntr3');
				if (ctr_messages) {
					for (var i=0; i<Gatekeeper.mnl.length; i++) {
						if (l >= Gatekeeper.mnl[i] && l < Gatekeeper.mnh[i]) {
							ctr_messages.value = i + Gatekeeper.localize('from') + (Gatekeeper.mnl.length-1);
							break;
						}
					}
				}
			} finally {
				Gatekeeper.countCharactersLock = false;
			}
		}
	},
	initPositionAndCountCharacters: function() {
		Gatekeeper.initPosition();
		Gatekeeper.countCharacters();
	},

	simple: function(event) {
		event.stop();
		$('link-simple').hide();
		$('link-advanced').show();
		$('field-advanced').disable();
		$$('.gk-advanced').invoke('hide');
	},
	advanced: function(event) {
		event.stop();
		$('link-simple').show();
		$('link-advanced').hide();
		$('field-advanced').enable();
		$$('.gk-advanced').invoke('show');
	},

	storeSMS: function(event) {
		event.stop();
		new Ajax.Request('closed/servlet/store-sms', {
			parameters: {
				recipients: $F('recipients'),
				email: $F('email'),
				text: $F('text'),
				advanced: $F('field-advanced'),
				confirmation: $F('confirmation_2') || $F('confirmation_1') || $F('confirmation_0'),
				mtype: $F('mtype_1') || $F('mtype_0')
			},
			onSuccess: function (transport) {
				window.location = 'mms.jsp';
			},
			onFailure: function (transport) {
				Gatekeeper.failure('store');
				window.setTimeout("window.location='mms.jsp';", 1500);
			}
		});
		Gatekeeper.hit();
	},
	storeMMS: function(event) {
		event.stop();
		new Ajax.Request('closed/servlet/store-mms', {
			parameters: {
				recipients: $F('recipients'),
				email: $F('email'),
				subject: $F('subject'),
				text: $F('text'),
				advanced: $F('field-advanced'),
				confirmation: ($('confirmation_1') && $F('confirmation_1')) || ($('confirmation_0') && $F('confirmation_0')) || false
			},
			onSuccess: function (transport) {
				window.location = 'closed.jsp';
			},
			onFailure: function (transport) {
				Gatekeeper.failure('store');
				window.setTimeout("window.location='closed.jsp';", 1500);
			}
		});
		Gatekeeper.hit();
	},

	quickSubmit: function(event) {
		if (event.keyCode == Event.KEY_RETURN && event.ctrlKey) {
			event.stop();
			$('send').click();
		}
	},

	initialize: function () {
		$$('.hidden').invoke('show');
		Gatekeeper.hideSmileysHandler = Gatekeeper.hideSmileys.bindAsEventListener(Gatekeeper);
		Gatekeeper.hideSmileys();

		var text = $('text');
		if (text) {
			text.observe('select', Gatekeeper.initPosition.bindAsEventListener(Gatekeeper));
			['mousemove', 'blur', 'change'].each(function(event){text.observe(event, Gatekeeper.countCharacters.bindAsEventListener(Gatekeeper));});
			['click', 'keyup', 'focus'].each(function(event){text.observe(event, Gatekeeper.initPositionAndCountCharacters.bindAsEventListener(Gatekeeper));});
		}

		var e = $('js.pack');
		if (e) e.observe('click', Gatekeeper.compressMessage.bindAsEventListener(Gatekeeper));
		e = $('js.back');
		if (e) e.observe('click', Gatekeeper.undoMessage.bindAsEventListener(Gatekeeper));
		e = $('js.show');
		if (e) e.observe('click', Gatekeeper.showSmileys.bindAsEventListener(Gatekeeper));
		
		$$('#smajlici a').each(function(element){element.observe('click', Gatekeeper.addSmiley.bindAsEventListener(Gatekeeper, element))});

		[ 'gt-message', 'gt-errormessage', 'gt-detail', 'gt-help' ].each (function (id) {
			var div = $(id);
			if (div) {
				div.getElementsBySelector('a,input').each(function (element) {
					element.observe('click', function (event) {
						event.stop();
						$(id).hide();
					});
				});
			}
		});

		e = $('link-simple');
		if (e) e.observe('click', Gatekeeper.simple.bindAsEventListener(Gatekeeper));
		e = $('link-advanced');
		if (e) e.observe('click', Gatekeeper.advanced.bindAsEventListener(Gatekeeper));

		Gatekeeper.initPosition();
		Gatekeeper.countCharacters();
		if (Gatekeeper.delay > 0) {
			Gatekeeper.blockSend();
			e = $('send');
			if (e) {
				e.title = Gatekeeper.localize('delayEnforced');
			}
			window.setTimeout("Gatekeeper.unblockSend()", 1000*Gatekeeper.delay);
		}

		e = $('killNonTMCZ');
		if (e) {
			e.observe('click', function (event) {
				event.stop();
				$$('.NonTMCZ').each(function (elem) {
					elem.checked = false;
				});
				$$('.TMCZ').each(function (elem) {
					elem.checked = true;
				});
			});
		}

		e = $('isTMCZhelp');
		if (e) {
			e.observe('click', function (event) {
				event.stop();
				$('gt-help').show();
			});
			e.style.visibility = '';
		}

		e = $('recipient') || $('recipients');
		if (e) {
			if (e.value.length < 9) e.focus();
			else {
				e = $('subject');
				if (e && e.value.length == 0) e.focus();
				else {
					e = $('text');
					if (e) e.focus();
				}
			}
		}

		$$('a[href="closed.jsp"]').each (function (a) {
			a.observe('click', Gatekeeper.storeMMS.bindAsEventListener(Gatekeeper));
		});
		$$('a[href="mms.jsp"]').each (function (a) {
			a.observe('click', Gatekeeper.storeSMS.bindAsEventListener(Gatekeeper));
		});
		
		$$('#gt-message a').each (function (a) {
			a.observe('click', function (event) {
				event.stop();
				$('gt-message').hide();
			});
		});
		e = $('gt-message-more-time');
		if (e) e.observe('click', Gatekeeper.moreTime.bindAsEventListener(Gatekeeper));
		e = $('gt-message-send');
		if (e) e.observe('click', function (event) {
			event.stop();
			$('send').click();
		});
		Gatekeeper.hit();

		['recipient', 'recipients', 'email', 'subject', 'text' ].each(function (id) {
			var e = $(id);
			if (e) e.observe('keyup', Gatekeeper.quickSubmit.bindAsEventListener(Gatekeeper));
		});
	}
};
