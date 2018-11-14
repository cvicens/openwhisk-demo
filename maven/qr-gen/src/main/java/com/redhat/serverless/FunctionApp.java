package com.redhat.serverless;

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.*;
import java.util.Base64;

import com.google.gson.JsonObject;
import com.google.zxing.*;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;

/**
 * QR Generator FunctionApp
 */
public class FunctionApp {
  public static JsonObject main(JsonObject args) {
	JsonObject response = new JsonObject();
	String text = args.getAsJsonPrimitive("text").getAsString();
	if (args == null || 
		args.getAsJsonPrimitive("text") == null || 
		args.getAsJsonPrimitive("text").getAsString() == null) {
		response.addProperty("error", "wrong parameters");
		
		return response;
	}
	
    try {
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      OutputStream b64os = Base64.getEncoder().wrap(baos);
      BitMatrix matrix = new MultiFormatWriter().encode(text, BarcodeFormat.QR_CODE, 300, 300);
      
      MatrixToImageWriter.writeToStream(matrix, "png", b64os);
      
      b64os.close();
      
      String output = baos.toString("utf-8");
      response.addProperty("qr", output);
    } catch (Throwable t) {
      response.addProperty("error", t.getMessage());
    }
    
    return response;
  }
}
