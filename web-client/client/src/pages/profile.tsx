import { useState } from "react";
import { 
  User, 
  Settings, 
  Bell, 
  Shield, 
  Star, 
  UserCircle, 
  Lock, 
  RefreshCw, 
  Save,
  ChevronRight,
  Palette
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { AIAlertGenerator } from "@/components/tools/alerts/ai-alert-generator";
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from "@/components/ui/avatar";
import { useToast } from "@/hooks/use-toast";

const UserProfile = () => {
  // User info state
  const [userInfo, setUserInfo] = useState({
    username: "test",
    email: "user@example.com",
    fullName: "Fantasy Manager",
    teamName: "Bont's Brigade",
    about: "Passionate fantasy football manager since 2018. Love strategizing and finding those hidden gems!",
    imageUrl: "",
  });
  
  // Settings state
  const [settings, setSettings] = useState({
    darkMode: true,
    emailNotifications: true,
    appNotifications: true,
    publicProfile: false,
    showRank: true,
    showTeamValue: true,
    autoOptimize: false,
    themeColor: "blue",
    dataSync: "weekly",
  });
  
  // Edit states
  const [isEditing, setIsEditing] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  const [passwords, setPasswords] = useState({
    current: "",
    new: "",
    confirm: "",
  });
  
  const [activeTab, setActiveTab] = useState("profile");
  const { toast } = useToast();
  
  // Handle user info update
  const handleUserInfoChange = (field: string, value: string) => {
    setUserInfo({ ...userInfo, [field]: value });
  };
  
  // Handle settings change
  const handleSettingChange = (field: string, value: any) => {
    setSettings({ ...settings, [field]: value });
  };
  
  // Handle password fields change
  const handlePasswordChange = (field: string, value: string) => {
    setPasswords({ ...passwords, [field]: value });
  };
  
  // Handle save profile
  const handleSaveProfile = () => {
    // In a real app, this would save to the API
    setIsEditing(false);
    toast({
      title: "Profile Saved",
      description: "Your profile information has been updated successfully.",
    });
  };
  
  // Handle change password
  const handleChangePassword = () => {
    // Password validation
    if (passwords.new !== passwords.confirm) {
      toast({
        title: "Passwords Don't Match",
        description: "New password and confirmation don't match. Please try again.",
        variant: "destructive",
      });
      return;
    }
    
    if (passwords.new.length < 8) {
      toast({
        title: "Password Too Short",
        description: "Password must be at least 8 characters long.",
        variant: "destructive",
      });
      return;
    }
    
    // In a real app, this would save to the API
    setIsChangingPassword(false);
    setPasswords({
      current: "",
      new: "",
      confirm: "",
    });
    
    toast({
      title: "Password Changed",
      description: "Your password has been updated successfully.",
    });
  };
  
  // Handle save settings
  const handleSaveSettings = () => {
    // In a real app, this would save to the API
    toast({
      title: "Settings Saved",
      description: "Your settings have been updated successfully.",
    });
  };
  
  return (
    <div className="container max-w-5xl py-6">
      <h1 className="text-3xl font-bold mb-6">User Profile</h1>
      
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="profile" className="flex items-center gap-2">
            <UserCircle className="h-4 w-4" />
            <span>Profile</span>
          </TabsTrigger>
          <TabsTrigger value="settings" className="flex items-center gap-2">
            <Settings className="h-4 w-4" />
            <span>Settings</span>
          </TabsTrigger>
          <TabsTrigger value="notifications" className="flex items-center gap-2">
            <Bell className="h-4 w-4" />
            <span>Notifications</span>
          </TabsTrigger>
        </TabsList>
        
        {/* Profile Tab */}
        <TabsContent value="profile" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card className="col-span-1">
              <CardHeader>
                <CardTitle className="text-xl">Profile Picture</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col items-center">
                <Avatar className="h-32 w-32">
                  <AvatarImage src={userInfo.imageUrl} />
                  <AvatarFallback className="text-3xl bg-primary text-primary-foreground">
                    {userInfo.username.substring(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                <Button variant="outline" className="mt-4 w-full">
                  Upload New Image
                </Button>
              </CardContent>
            </Card>
            
            <Card className="col-span-1 md:col-span-2">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-xl">Personal Information</CardTitle>
                  <CardDescription>Update your personal details</CardDescription>
                </div>
                <Button 
                  variant={isEditing ? "default" : "outline"} 
                  onClick={() => isEditing ? handleSaveProfile() : setIsEditing(true)}
                >
                  {isEditing ? (
                    <>
                      <Save className="mr-2 h-4 w-4" />
                      Save
                    </>
                  ) : (
                    "Edit Profile"
                  )}
                </Button>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="fullName">Full Name</Label>
                    <Input
                      id="fullName"
                      value={userInfo.fullName}
                      onChange={(e) => handleUserInfoChange("fullName", e.target.value)}
                      disabled={!isEditing}
                    />
                  </div>
                  <div>
                    <Label htmlFor="username">Username</Label>
                    <Input
                      id="username"
                      value={userInfo.username}
                      onChange={(e) => handleUserInfoChange("username", e.target.value)}
                      disabled={!isEditing}
                    />
                  </div>
                </div>
                
                <div>
                  <Label htmlFor="email">Email Address</Label>
                  <Input
                    id="email"
                    value={userInfo.email}
                    onChange={(e) => handleUserInfoChange("email", e.target.value)}
                    disabled={!isEditing}
                  />
                </div>
                
                <div>
                  <Label htmlFor="teamName">Team Name</Label>
                  <Input
                    id="teamName"
                    value={userInfo.teamName}
                    onChange={(e) => handleUserInfoChange("teamName", e.target.value)}
                    disabled={!isEditing}
                  />
                </div>
                
                <div>
                  <Label htmlFor="about">About</Label>
                  <textarea
                    id="about"
                    rows={3}
                    className="w-full border rounded-md p-2"
                    value={userInfo.about}
                    onChange={(e) => handleUserInfoChange("about", e.target.value)}
                    disabled={!isEditing}
                  />
                </div>
              </CardContent>
            </Card>
            
            <Card className="col-span-1 md:col-span-3">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-xl">Security</CardTitle>
                  <CardDescription>Manage your account security</CardDescription>
                </div>
                <Button 
                  variant={isChangingPassword ? "default" : "outline"} 
                  onClick={() => isChangingPassword ? handleChangePassword() : setIsChangingPassword(true)}
                >
                  {isChangingPassword ? (
                    <>
                      <Save className="mr-2 h-4 w-4" />
                      Change Password
                    </>
                  ) : (
                    "Change Password"
                  )}
                </Button>
              </CardHeader>
              <CardContent>
                {isChangingPassword ? (
                  <div className="space-y-4">
                    <div>
                      <Label htmlFor="currentPassword">Current Password</Label>
                      <Input
                        id="currentPassword"
                        type="password"
                        value={passwords.current}
                        onChange={(e) => handlePasswordChange("current", e.target.value)}
                      />
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="newPassword">New Password</Label>
                        <Input
                          id="newPassword"
                          type="password"
                          value={passwords.new}
                          onChange={(e) => handlePasswordChange("new", e.target.value)}
                        />
                      </div>
                      <div>
                        <Label htmlFor="confirmPassword">Confirm New Password</Label>
                        <Input
                          id="confirmPassword"
                          type="password"
                          value={passwords.confirm}
                          onChange={(e) => handlePasswordChange("confirm", e.target.value)}
                        />
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="flex items-center gap-4">
                    <Shield className="h-8 w-8 text-primary" />
                    <div>
                      <p className="font-medium">Password</p>
                      <p className="text-sm text-gray-500">••••••••••••</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>
        
        {/* Settings Tab */}
        <TabsContent value="settings" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">App Settings</CardTitle>
              <CardDescription>Customize your app experience</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Dark Mode</Label>
                      <p className="text-sm text-gray-500">Use dark theme for the application</p>
                    </div>
                    <Switch
                      checked={settings.darkMode}
                      onCheckedChange={(checked) => handleSettingChange("darkMode", checked)}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Theme Color</Label>
                    <Select
                      value={settings.themeColor}
                      onValueChange={(value) => handleSettingChange("themeColor", value)}
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="Select theme color" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="blue">Blue</SelectItem>
                        <SelectItem value="green">Green</SelectItem>
                        <SelectItem value="purple">Purple</SelectItem>
                        <SelectItem value="red">Red</SelectItem>
                        <SelectItem value="orange">Orange</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Data Synchronization</Label>
                    <Select
                      value={settings.dataSync}
                      onValueChange={(value) => handleSettingChange("dataSync", value)}
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="Select sync frequency" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="realtime">Real-time</SelectItem>
                        <SelectItem value="hourly">Hourly</SelectItem>
                        <SelectItem value="daily">Daily</SelectItem>
                        <SelectItem value="weekly">Weekly</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Public Profile</Label>
                      <p className="text-sm text-gray-500">Make your profile visible to other users</p>
                    </div>
                    <Switch
                      checked={settings.publicProfile}
                      onCheckedChange={(checked) => handleSettingChange("publicProfile", checked)}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Show Rank</Label>
                      <p className="text-sm text-gray-500">Display your rank on your profile</p>
                    </div>
                    <Switch
                      checked={settings.showRank}
                      onCheckedChange={(checked) => handleSettingChange("showRank", checked)}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Show Team Value</Label>
                      <p className="text-sm text-gray-500">Display your team value on your profile</p>
                    </div>
                    <Switch
                      checked={settings.showTeamValue}
                      onCheckedChange={(checked) => handleSettingChange("showTeamValue", checked)}
                    />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Auto Optimize</Label>
                      <p className="text-sm text-gray-500">Automatically apply AI-suggested optimizations</p>
                    </div>
                    <Switch
                      checked={settings.autoOptimize}
                      onCheckedChange={(checked) => handleSettingChange("autoOptimize", checked)}
                    />
                  </div>
                </div>
              </div>
            </CardContent>
            <CardFooter>
              <Button onClick={handleSaveSettings}>
                <Save className="mr-2 h-4 w-4" />
                Save Settings
              </Button>
            </CardFooter>
          </Card>
          
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">Theme Preview</CardTitle>
              <CardDescription>See how your theme settings look</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
                <Button variant="default">Primary</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="outline">Outline</Button>
                <Button variant="destructive">Destructive</Button>
              </div>
              
              <div className={`mt-4 p-4 rounded-md ${settings.darkMode ? 'bg-gray-800 text-white' : 'bg-white border text-gray-800'}`}>
                <p className="text-sm font-medium">Theme Preview</p>
                <p className="text-xs opacity-80">This is how your selected theme will look</p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Notifications Tab */}
        <TabsContent value="notifications" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">Notification Settings</CardTitle>
              <CardDescription>Manage how you receive notifications</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label>Email Notifications</Label>
                    <p className="text-sm text-gray-500">Receive important updates via email</p>
                  </div>
                  <Switch
                    checked={settings.emailNotifications}
                    onCheckedChange={(checked) => handleSettingChange("emailNotifications", checked)}
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label>App Notifications</Label>
                    <p className="text-sm text-gray-500">Receive notifications within the app</p>
                  </div>
                  <Switch
                    checked={settings.appNotifications}
                    onCheckedChange={(checked) => handleSettingChange("appNotifications", checked)}
                  />
                </div>
              </div>
            </CardContent>
            <CardFooter>
              <Button onClick={handleSaveSettings}>
                <Save className="mr-2 h-4 w-4" />
                Save Notification Settings
              </Button>
            </CardFooter>
          </Card>
          
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">AI Alert Configuration</CardTitle>
              <CardDescription>Configure your AI-powered alerts</CardDescription>
            </CardHeader>
            <CardContent>
              <AIAlertGenerator />
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default UserProfile;