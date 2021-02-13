package com.perol.pixez

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.net.http.SslError
import android.os.Bundle
import android.view.Menu
import android.webkit.*
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_webview.*

class WebViewActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val url = intent.getStringExtra("url")!!
        setContentView(R.layout.activity_webview)
        webView.settings.javaScriptEnabled = true
        setSupportActionBar(toolbar)
        supportActionBar!!.setDisplayHomeAsUpEnabled(true)
        toolbar.setNavigationOnClickListener { finish() }
        toolbar.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.browser -> {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                }
                R.id.refresh -> {
                    webView.reload()
                }
            }
            true
        }
        val webViewClient = object : WebViewClient() {
            override fun onReceivedSslError(view: WebView?, handler: SslErrorHandler?, error: SslError?) {
                handler?.proceed()
            }

            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                if (request?.url?.scheme == "pixiv") {
                    Weiss.invokeDart(request.url?.toString()!!)
                    finish()
                    return true
                }
                if (request?.url?.host == "www.pixiv.net") {
                    return true
                }
                return super.shouldOverrideUrlLoading(view, request)
            }

            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                toolbar.title = "Loading..."
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                toolbar.title = "Login"
                webView.loadUrl("javascript:(function() { " +
                        "document.getElementsByClassName('signup-form__sns-btn-area')[0].style.display='none'; })()");
            }
        }
        webView.webViewClient = webViewClient
        webView.loadUrl(url)
    }


    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_webview, menu)
        return super.onCreateOptionsMenu(menu)
    }

    override fun onDestroy() {
        Weiss.stop()
        super.onDestroy()
    }
}