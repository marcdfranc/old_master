package com.marcsoftware.utilities;

import java.awt.Font;
import java.awt.Rectangle;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.eclipse.jdt.internal.compiler.ast.ThisReference;

import jbarcodebean.Codabar;
import jbarcodebean.Code11;
import jbarcodebean.Code128;
import jbarcodebean.Code39;
import jbarcodebean.Code93;
import jbarcodebean.Code93Extended;
import jbarcodebean.Ean13;
import jbarcodebean.Ean8;
import jbarcodebean.ExtendedCode39;
import jbarcodebean.Interleaved25;
import jbarcodebean.JBarcodeBean;
import jbarcodebean.MSI;

public class BarcodeFactory implements Runnable {
	private JBarcodeBean bean;	
	private File file, folder;
	private TempManager manager;
	private static String path;
	
	public BarcodeFactory(String path) {
		this.path = path.replace('\\', '/');
		folder= new File(path);
		if (!folder.exists()) {
			folder.mkdir();
		}
	}
	

	public void run() {
		int aux = 0;
		folder= new File(path);		
		while (folder.exists()) {
			try {
				Thread.sleep(25000);
				if (aux++ > 3) {
					TempManager manager = new TempManager(2);
					manager.cleanTemp();
				}
			} catch (InterruptedException e) {				
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * 
	 * @param codigo -> Codigo a ser gerado
	 * @param tipo -> tipo do codigo
	 * 0 = code 128, 1 = code 11, 2= Intervaled code 25,
	 * 3 = code 39, 4 = Extended code 39, 5 = code 93
	 * 6 = Extended code 93, 7 = codabar, 8 = MSI
	 * 9 = EAN-13, 10 = EAN-8.
	 * @return true se gerado, false se ocorrer erro
	 */
	
	public  boolean generateBarcode(String codigo, int tipo, int height, int textHeight, boolean text) {
		try {
			file = new File(folder, Util.removeZeroLeft(codigo) + ".gif");
			bean = new JBarcodeBean();
			switch (tipo) {
			case 0:
				bean.setCodeType(new Code128());
				break;

			case 1:
				bean.setCodeType(new Code11());
				break;
				
			case 2:
				bean.setCodeType(new Interleaved25());
				break;
				
			case 3:
				bean.setCodeType(new Code39());
				break;
				
			case 4:
				bean.setCodeType(new ExtendedCode39());
				break;
				
			case 5:
				bean.setCodeType(new Code93());
				break;
				
			case 6:
				bean.setCodeType(new Code93Extended());
				break;
				
			case 7:
				bean.setCodeType(new Codabar());
				break;
				
			case 8:
				bean.setCodeType(new MSI());
				break;
				
			case 9:
				bean.setCodeType(new Ean13());
				break;
				
			case 10:
				bean.setCodeType(new Ean8());
				break;
				
			case 11:
				bean.setCodeType(new Code11());
				break;
			}
			bean.setShowText(text);
			bean.setBarcodeHeight(height);			
			bean.setCode(codigo);
			if (text) {
				bean.setFont(new Font("Arial", Font.PLAIN, textHeight));				
			}
			bean.gifEncode(new FileOutputStream(file));
		} catch (Exception e) {
			e.printStackTrace();
			run();
			return false;
		}
		return true;		
	}
	
	public void createXml(String text) throws IOException {		
		FileWriter writer = new FileWriter(this.path + "/carteirinha.xml", true);
		writer.write(text);
		writer.close();
	}
	
	public void close() {
		manager = new TempManager(3);
		ExecutorService threadExec= Executors.newSingleThreadScheduledExecutor();
		threadExec.execute(manager);		
	}
	
	
	private static class TempManager implements Runnable {		
		private long sleepTime;
		
		public TempManager(long sleepTime) {
			this.sleepTime = sleepTime *(60 * 100);
		}
		
		public void run() {
			try {
				Thread.sleep(this.sleepTime);			
				cleanTemp();			
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		public boolean cleanTemp() {
			File child;
			try {
				File folder = new File(path);				
				if (folder.exists()) {
					if (folder.isDirectory()) {
						for (String ch : folder.list()) {
							child = new File(folder, ch);
							if (!child.delete()) {
								return false;
							}
						}
						if (!folder.delete()) {
							return false;
						}
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
			return true;
		}	
	}
}

