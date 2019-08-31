package com.marcsoftware.utilities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

import jbarcodebean.Code128;
import jbarcodebean.JBarcodeBean;

import org.apache.commons.codec.digest.DigestUtils;
import org.eclipse.birt.report.engine.api.script.IReportContext;
import org.eclipse.birt.report.engine.api.script.eventadapter.ImageEventAdapter;
import org.eclipse.birt.report.engine.api.script.instance.IImageInstance;

public class CodigoDeBarra extends ImageEventAdapter{
	private FileInputStream in;
	
	@Override
	public void onCreate(IImageInstance image, IReportContext reportContext) {
		try {
			String code= "7441312";
			//File file = new File(System.getProperty("java.io.tmpdir"), DigestUtils.md5Hex(code));
			File file = File.createTempFile("rel", DigestUtils.md5Hex(code));
			if (!file.exists()) {
				JBarcodeBean bean= new JBarcodeBean();
				bean.setCodeType(new Code128());
				bean.setShowText(true);
				bean.gifEncode(new FileOutputStream(file));
				bean.setBarcodeHeight(45);
				bean.setCode(code);
			}
			//image.setFile(file.getAbsolutePath());			
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}
}
