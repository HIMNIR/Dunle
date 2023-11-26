package com.example.dunble

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val getStarted = findViewById<Button>(R.id.startBtn)
        getStarted.setOnClickListener(){
            openHome();
        }


    }
    fun openHome(){
        val intent = Intent(this,MapsActivity::class.java)
        startActivity(intent)
    }
}