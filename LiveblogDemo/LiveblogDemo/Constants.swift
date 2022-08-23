import Foundation

struct Constants {
//	static let embedUrl = URL(string: "https://cdn.tickaroo.com/embed/v4/fullpage/5d2d9526560ace9935c7218a/fplP8VNyRxRn8V5KWQ4a4UnYyS8MIo.html")!
    static let embedUrl = URL(string: "https://staging-cdn.tickaroo.com/embed/v4/fullpage/57d6a6bbe4b0cc1b8e5871b0/fplqQJUc0fuVuuRvDHMHJ21oF8TPhg.html")!
//    static let embedCode = """
//<html>
//    <head>
//        <title>Live Blog Embed Demo</title>
//        <meta name="viewport" content="width=device-width, initial-scale=1">
//    </head>
//    <body>
//        <script async src="https://cdn.tickaroo.com/webng/embedjs/tik4.js"></script>
//        <tickaroo-liveblog liveblogId="62fe403f7fcc1170ab0151fd" themeId="lct_62fe4237202c865a30879595" clientId="5d2d9526560ace9935c7218a" />
//    </body>
//</html>
//"""
//}

    static let embedCode = """
<html>
	<head>
		<title>Live Blog Embed Demo</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
	</head>
	<body>
        <script async src="https://cdn.tickaroo.com/webng/embedjs/tik4.js"></script>
        <tickaroo-liveblog liveblogId="625ebe387f6702633fa183a3" themeId="lct_615d9309d782230aa8c59acb" clientId="57d6a6bbe4b0cc1b8e5871b0" />
	</body>
</html>
"""
}
