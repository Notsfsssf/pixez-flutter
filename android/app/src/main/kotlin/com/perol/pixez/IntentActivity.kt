/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.perol.pixez

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.FrameLayout
import android.widget.TextView
import androidx.fragment.app.FragmentActivity
import io.flutter.Log

class IntentActivity : FragmentActivity() {
    private var textView: TextView? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        textView = TextView(this@IntentActivity)
        setContentView(FrameLayout(this).apply {
            addView(textView)
        })
        parseIntent(intent)
    }

    private fun parseIntent(intent: Intent?) {
        val iid = intent?.getLongExtra("iid", 0)
        Log.d("IntentActivity", "Card app widget:${iid}")
        val targetIntent = Intent(this, MainActivity::class.java)
        if (iid != 0L) {
            textView?.text = iid.toString()
            targetIntent.action = Intent.ACTION_VIEW
            val uri = Uri.parse("pixez://www.pixiv.net/artworks/$iid")
            targetIntent.data = uri
        }
        startActivity(targetIntent)
        finish()
    }
}