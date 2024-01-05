import WebKit

/// A wrapper around WebView js function callbacks
/// - Parameters:
///   - functionName: The name of the function in java script.
///   - params: An array of strings, each representing a parameter in the function.
///   - callback: This callback will be called when the actual js function is called, passing a `Dictionary<String: AnyObject>` where there will be a key for each parameter.
public class JSHandler: NSObject {
	private enum JSHandlerType {
		case scriptInvoke(String)
		case functionCallback(functionName: String, params: [String], callback: ([String: AnyObject]) -> Void)
		case customCallback(script: String, functionName: String, callback: ([String: AnyObject]) -> Void)

		var callbackFunctionName: String {
			switch self {
			case let .scriptInvoke(script):
				return String(script.prefix(10)) + "Swift"
			case let .functionCallback(functionName: functionName, params: _, callback: _):
				return functionName + "Swift"
			case let .customCallback(script: _, functionName: functionName, callback: _):
				return functionName
			}
		}

		var callback: (([String: AnyObject]) -> Void)? {
			switch self {
			case .scriptInvoke:
				return nil
			case let .functionCallback(functionName: _, params: _, callback: callback):
				return callback
			case let .customCallback(script: _, functionName: _, callback: callback):
				return callback
			}
		}
	}
	
	private let handlerType: JSHandlerType
	fileprivate let injectionTime: WKUserScriptInjectionTime

	public init(functionName: String, params: [String] = [], callback: @escaping (([String: AnyObject]) -> Void)) {
		self.handlerType = .functionCallback(functionName: functionName, params: params, callback: callback)
		self.injectionTime = .atDocumentStart
	}

	public init(script: String, functionName: String, callback: @escaping (([String: AnyObject]) -> Void)) {
		self.handlerType = .customCallback(script: script, functionName: functionName, callback: callback)
		self.injectionTime = .atDocumentStart
	}

	public init(script: String, injectionTime: WKUserScriptInjectionTime) {
		self.handlerType = .scriptInvoke(script)
		self.injectionTime = injectionTime
	}

	private var paramsAsString: ([String]) -> String = { $0.joined(separator: ",") }
	private var paramsAsStringDict: ([String]) -> String = { $0.map({ "\($0):\($0)"}).joined(separator: ",") }

	var script: String {
		switch handlerType {
		case let .scriptInvoke(script):
			return script
		case let .functionCallback(functionName: functionName, params: params, callback: _):
			return "function \(functionName)(\(paramsAsString(params))){window.webkit.messageHandlers.\(callbackFunctionName).postMessage({\(paramsAsStringDict(params))});};"
		case let .customCallback(script: script, functionName: _, callback: _):
			return script
		}
	}
	
	var callback: (([String: AnyObject]) -> Void)? { handlerType.callback }
	var callbackFunctionName: String { handlerType.callbackFunctionName }
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
	private var callbacksDict: [String: JSHandler] = [:]
	private let contentController = WKUserContentController()
	let config = WKWebViewConfiguration()

	init(callbacks: [JSHandler]) {
		super.init()

		for callback in callbacks {
			callbacksDict[callback.callbackFunctionName] = callback
			contentController.addUserScript( WKUserScript(
				source: callback.script,
				injectionTime: WKUserScriptInjectionTime.atDocumentStart,
				forMainFrameOnly: true
			))

			contentController.add(self, name: callback.callbackFunctionName)
		}

		config.userContentController = contentController
	}

	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard let callback = callbacksDict[message.name],
			  let params = message.body as? [String: AnyObject] else { return }

		callback.callback!(params)
	}
}
