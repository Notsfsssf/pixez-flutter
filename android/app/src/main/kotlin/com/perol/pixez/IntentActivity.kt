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
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentActivity

class IntentActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val textView = TextView(this@IntentActivity)
        setContentView(FrameLayout(this).apply {
            addView(textView)
        })
        val iid = intent.getLongExtra("iid", 0)
        textView.text= iid.toString()
        if (iid == 0L)
            startActivity(Intent(this, MainActivity::class.java))
        else {
            val uri: Uri = Uri.parse("pixez://www.pixiv.net/artworks/$iid")
            val intent = Intent(Intent.ACTION_VIEW, uri)
            startActivity(intent)
            finish()
        }
    }
}