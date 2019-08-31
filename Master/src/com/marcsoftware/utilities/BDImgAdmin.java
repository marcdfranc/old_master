package com.marcsoftware.utilities;

import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.imageio.ImageIO;

import org.apache.commons.fileupload.FileItem;


public class BDImgAdmin {
	private String path, fileName, extencion;
	private File folder, file;
	private FileOutputStream output;
	private InputStream input;	
	private FileItem data;
	
	
	public BDImgAdmin(String context) {
		path= context + "/";
	}
	
	public void createfolder(String newFolder) {
		if (newFolder == null) {
			folder= new File(path);			
		} else {
			folder= new File(path + newFolder);
		}
		if (!folder.exists()) {
			folder.mkdir();
		}
	}
	
	public void createFile(String newFile, String extension, String newFolder) {		
		if (newFolder!= null) {
			createfolder(newFolder);
		} 
		this.extencion = extension;
		fileName = newFile + "." + this.extencion;
		file= new File(folder, fileName);			
	}
	
	public File getFile() {
		return file;
	}
	
	public void copyData(FileItem newData) throws IOException {
		data= newData;
		output= new FileOutputStream(file);
		input= data.getInputStream();
		byte buffer[]= new byte[2048];
		int nRead;
		while ((nRead= input.read(buffer)) > 0) {
			output.write(buffer, 0, nRead);
		}		
		output.flush();
		output.close();		
	}
	
	public void createThumb(String thumbPath, String thumbName, String extension) {
		try {
			BufferedImage NaturalImage = ImageIO.read(file);
			BufferedImage thumb = Util.getScaledInstance(NaturalImage, 250, 47, RenderingHints.VALUE_INTERPOLATION_BILINEAR , true);
			File output = new File(thumbPath + "/" + thumbName + "." + extension);
			ImageIO.write(thumb, extension, output);
		} catch (IOException e) {			
			e.printStackTrace();
		}
	}
	
	public void redimensionar(int width, int height, Object hint, boolean highQuality) {
		try {
			BufferedImage NaturalImage = ImageIO.read(file);
			BufferedImage newImage = Util.getScaledInstance(NaturalImage, 250, 47, hint , highQuality);
			File output = new File(folder, fileName);
			ImageIO.write(newImage, this.extencion, output);
		} catch (IOException e) {			
			e.printStackTrace();
		}
	}
	
	public void deleteFile() {
		if (file.exists()) {
			file.delete();
		}
	}
}
