/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail
{
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;
	
	import com.coltware.airxmail_internal;
	use namespace airxmail_internal;
	
	public class ContentType extends MimeHeader
	{
		include "../airxmail.as";
		
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.ContentType");
		
		public static const MULTIPART_MIXED:String = "multpart/mixed";
		public static const MULTIPART_ALTERNATIVE:String = "multipart/alternative";
		
		private var _mainType:String ;
		private var _subType:String;
		
		private var _isBinary:Boolean = false;
		
		public function ContentType()
		{
			this.key = "content-type";
		}
		
		public function getMainType():String{
			return this._mainType;
		}
		public function getSubStype():String{
			return this._subType;
		}
		
		public function setMainType(v:String):void{
			if(v == "text"){
				this._isBinary = false;
			}
			else{
				this._isBinary = true;
			}
			this._mainType = v;
		}
		public function setSubStype(v:String):void{
			this._subType = v;
		}
		
		/**
		 * マルチパートのコンテントタイプか
		 * 
		 */
		public function isMultipart():Boolean{
			if(_mainType == "multipart"){
				return true;
			}
			else{
				return false;
			}
		}
		
		public function isBinary():Boolean{
			return this._isBinary;
		}
		
		public function isText():Boolean{
			if(_mainType == "text"){
				return true;
			}
			else{
				return false;
			}
		}
		
		public function getValue():String{
			
			var ret:String = this._mainType + "/" + this._subType;
			var p:Array = new Array();
			for(var key:String in _params){
				var str:String = key + "=\"" + _params[key] + "\"";
				//str = "\n\t" + str;
				p.push(str);
			}
			if(p.length > 0 ){
				ret += ";" + p.join(";");
			}
			return ret;
		}
		
		public static function parseValue(str:String):ContentType{
			var ct:ContentType = new ContentType();
			str = StringUtil.trim(str);
			var p:Array = str.split(";");
			for(var i:int = 0; i<p.length; i++){
				if(i==0){
					var tmp1:Array = p[i].split("/");
					ct.setMainType(tmp1[0]);
					ct.setSubStype(tmp1[1]);
				}
				else{
					var key2:String = p[i];
					var eq:int = key2.indexOf("=");
					var c:String = "";
					if(eq){
						c	 = key2.substring(eq+1,key2.length);
						key2 = key2.substr(0,eq);
						key2 = StringUtil.trim(key2);
					}
					var fc:String = c.charAt(0);
					if(fc == "\"" || fc == "'"){
						ct.setParameter(key2,c.substring(1,c.length - 1));
					}
					else{
						ct.setParameter(key2,StringUtil.trim(c));
					}
				}
			}
			return ct;
		}
		
		public static function newInstance(type:String,args:String = null):ContentType{
			var ct:ContentType;
			if(type == ContentType.MULTIPART_MIXED || type == ContentType.MULTIPART_ALTERNATIVE){
				ct = new ContentType();
				ct._mainType = "multipart";
				if(type == ContentType.MULTIPART_MIXED){
					ct._subType  = "mixed";
				}
				else{
					ct._subType = "alternative";
				}
				ct.setParameter("boundary","--Part-" + UIDUtil.createUID());	
				return ct;
			}
			log.debug("newInstance => " + ct.getValue());
			return ct;
		}
		
		override public function dumpLog():void{
			log.debug("type is " + this.getValue());
		}
	}
}