package getClimateStatus;
import javax.faces.annotation.SessionMap;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.lang.StringBuilder;
import java.util.List;
import java.util.ArrayList;
//import java.util.Arrays;
import java.net.HttpURLConnection;
import java.net.URL;

@SessionMap()
public class GetTemperature implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String putCity;
	String chk="", Temp="None", windSpeed="None", humidity="None", pressure="None";
	int N=6;
	
	List<Double> Lat = new ArrayList<Double>();
	List<Double> Lon = new ArrayList<Double>();
	
	private List<String> dTime = new ArrayList<String>();
	private List<String> ctime = new ArrayList<String>();
	private List<String> temp = new ArrayList<String>();
	private List<Integer> testTmp = new ArrayList<Integer>();
	
	private List<GetTemperature> view = new ArrayList<GetTemperature>(); 
	private String date="", time="", tmp="", state="";
	
	public GetTemperature() {
		
	}
	GetTemperature(String dt, String tm, String Tmp, String cond) {
		this.date=dt;
		this.time=tm;
		this.tmp=Tmp;
		this.state=cond;
	}
	
	/// TO SHOW DATE, CLOCK TIME, TEMPERATURE & CONDITION(warm, hot, cold)
	public String getDate() {
		return date;
	}
	public void setDate(String date) {
		this.date = date;
	}
	public String getTime() {
		return time;
	}
	public void setTime(String time) {
		this.time = time;
	}
	public String getTmp() {
		return tmp;
	}
	public void setTmp(String tmp) {
		this.tmp = tmp;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	
	public String getPutInfo() {
		return putCity;
	}

	public void setPutInfo(String putInfo) {
		this.putCity = putInfo;
	}
	
	public void setLimit(int num) {
		this.N=num;
	}
	
	public int getLimit() {
		return N;
	}
	
	//Retrieve Latitude & Longitude for Specific City...
	public void getJsonDataFromURL_01(String city) {
		try {
			String srcURL = "https://nominatim.openstreetmap.org/search?format=json&q="+city+"";
			
			//Get Http Connection from Active URL
			HttpURLConnection connection = (HttpURLConnection) new URL(srcURL).openConnection();
	        connection.setRequestMethod("GET");
	        
	        //Stream Loaded from Active Connection to Read Response
	        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	        StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            
            //Parsing JSON Response using Jackson...
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(response.toString());
            //JsonNode hourlyData = rootNode.path("hourly");
            
            //Extract Specific Data
            for(JsonNode item : rootNode) {
            	Lat.add(item.get("lat").asDouble());
            	Lon.add(item.get("lon").asDouble());
            }
            
            
            if (!Lat.isEmpty() && !Lon.isEmpty())
            	this.jsonDataFromURL_02(Lat.get(0).doubleValue(), Lon.get(0).doubleValue());
            else
            	System.out.println("NO DATA IN THE LIST VARIABLES...!");
            
		}catch(Exception Ex) {
			Ex.printStackTrace();
		}
	}
	//Retrieve Temperature, Humidity, Wind Speed, Pressure
	public void jsonDataFromURL_02(double lat, double lon) {
		try {
			String srcURL = "https://api.open-meteo.com/v1/forecast?latitude="+lat+"&longitude="+lon+"&hourly=temperature_2m,wind_speed_10m,relative_humidity_2m,pressure_msl&timezone=auto";
			
			//Get Http Connection from Active URL
			HttpURLConnection connection = (HttpURLConnection) new URL(srcURL).openConnection();
	        connection.setRequestMethod("GET");
	        
	        //Stream Loaded from Active Connection to Read Response
	        BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	        StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            
            //Parsing JSON Response using Jackson...
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(response.toString());
            JsonNode hourlyData = rootNode.path("hourly");
            
            //Extract Specific Data
            windSpeed=hourlyData.path("wind_speed_10m").get(0).toString();
            humidity=hourlyData.path("relative_humidity_2m").get(0).toString();
            pressure=hourlyData.path("pressure_msl").get(0).toString();
            
            for(short t=0; t<(hourlyData.path("temperature_2m").size()-(24*getLimit())); t++) {
            	String twoTokens[] = hourlyData.path("time").get(t).toString().split("T");
            	dTime.add(twoTokens[0]);
            	ctime.add(twoTokens[1]);
            	temp.add(hourlyData.path("temperature_2m").get(t).toString());
            	testTmp.add(hourlyData.path("temperature_2m").get(t).asInt());
            }
		}catch(Exception Ex) {
			Ex.printStackTrace();
		}
	}
	//Check Conditions based on Temperature Requirements
	String tempMode(int celsius) {
		String rst;
			
		if(celsius < 10)
			rst="Cold";
		else if(celsius >= 10 && celsius <= 25)
			rst="Cool";
		else if(celsius > 25 && celsius <= 29)
			rst="Warm";
		else
			rst="Hot";
			
		return rst;
	}
	public String getSimulated() {
		
		if(!dTime.isEmpty())
			dTime.removeAll(dTime);
		if(!ctime.isEmpty())
			ctime.removeAll(ctime);
		if(!temp.isEmpty())
			temp.removeAll(temp);
		if(!testTmp.isEmpty())
			testTmp.removeAll(testTmp);
		if(!Lat.isEmpty())
			Lat.removeAll(Lat);
		if(!Lon.isEmpty())
			Lon.removeAll(Lat);
		if(!view.isEmpty())
			view.removeAll(view);
		
		this.getJsonDataFromURL_01(this.getPutInfo());
		Temp=temp.get(0);
			
		//new GetTemperature[temp.size()]
		GetTemperature[] keyItm = new GetTemperature[temp.size()];
		for(short t=0; t<temp.size(); t++) {
			keyItm[t] = new GetTemperature(dTime.get(t), ctime.get(t), temp.get(t), tempMode(testTmp.get(t).intValue()));
			//this.setReport(new ArrayList<GetTemperature>(Arrays.asList(keyItm)));
			view.add(keyItm[t]);
		}
		return "Yes";
	}
	
	public void setReport(List<GetTemperature> data){
		this.view=data;
	}
	
	public List<GetTemperature> getReport(){
		return view;
	}
	
	public String getTempCard() {
		return this.Temp;
	}
	public String getWindCard() {
		return this.windSpeed;
	}
	public String getHumidCard() {
		return this.humidity;
	}
	public String getPressCard() {
		return this.pressure;
	}
}
