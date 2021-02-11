package com.perol.pixez

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import okhttp3.Dns
import okhttp3.OkHttpClient
import okhttp3.Request
import java.net.InetAddress
import java.net.Socket
import java.security.cert.X509Certificate
import javax.net.ssl.SSLSocket
import javax.net.ssl.SSLSocketFactory
import javax.net.ssl.X509TrustManager

class WebViewActivity : Activity() {
    lateinit var webView: WebView
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val url = intent.getStringExtra("url")
        webView = WebView(this)
        setContentView(webView)

        val webViewClient = object : WebViewClient() {
           val okHttpClient = OkHttpClient.Builder().apply {
                dns(object :Dns{
                    override fun lookup(hostname: String): List<InetAddress> {
                        val addressList = mutableListOf<InetAddress>()
                        if (hostname.contains("pixiv",ignoreCase = true)){
                            addressList.addAll(InetAddress.getAllByName("210.140.131.199"))
                        }
                        return addressList
                    }
                })
                sslSocketFactory(object : SSLSocketFactory() {

                    override fun getDefaultCipherSuites() = arrayOf<String>()

                    override fun getSupportedCipherSuites() = arrayOf<String>()

                    override fun createSocket(socket: Socket?, host: String?, port: Int, autoClose: Boolean): Socket {
                        val address = socket!!.inetAddress
                        if (autoClose) socket.close()
                        val sslSocket = (getDefault().createSocket(address, port) as SSLSocket).apply { enabledProtocols = supportedProtocols }
                        val sslSession = sslSocket.session
                        Log.i(
                                "!",
                                "Address: ${address.hostAddress}, Protocol: ${sslSession.protocol}, PeerHost: ${sslSession.peerHost}, CipherSuite: ${sslSession.cipherSuite}."
                        )
                        return sslSocket
                    }

                    override fun createSocket(host: String?, port: Int): Socket? = null

                    override fun createSocket(host: String?, port: Int, localHost: InetAddress?, localPort: Int): Socket? = null

                    override fun createSocket(address: InetAddress?, port: Int): Socket? = null

                    override fun createSocket(address: InetAddress?, port: Int, localAddress: InetAddress?, localPort: Int): Socket? = null
                }, object : X509TrustManager {
                    override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {
                    }

                    override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {
                    }

                    override fun getAcceptedIssuers(): Array<X509Certificate> {
                        return arrayOf()
                    }
                })
            }.build()
            override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse? {
                if(request!!.url.host!!.contains("pixiv")){
                }

                return super.shouldInterceptRequest(view, request)
            }

            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                if (request?.url?.scheme == "pixiv") {
                    return true
                }
                return super.shouldOverrideUrlLoading(view, request)
            }
        }
        webView.webViewClient = webViewClient
    }
}