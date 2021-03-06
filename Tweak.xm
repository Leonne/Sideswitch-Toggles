static NSBundle *customPlugin = nil;

%hook SpringBoard
-(void)ringerChanged:(int)changed
{	
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:
									[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.AndyIbanez.Sideswitch.plist"]];
	if(settings == nil)
	{
		settings = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"default", @"pluginToExecute", nil];
		[settings writeToFile:
					[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.AndyIbanez.Sideswitch.plist"]
				atomically:YES];
	}
	
	if([[settings objectForKey:@"pluginToExecute"] isEqualToString:@"default"])
	{
		%orig(changed);
	}else 
	{
		if(customPlugin == nil)
		{
			customPlugin = [[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"/Library/Sideswitch/plugins/%@", [settings objectForKey:@"pluginToExecute"], nil]];
		}
		
		Class loadedPluginClass;
		id loadedPlugin;
		if((loadedPluginClass = [customPlugin principalClass]))
		{
			loadedPlugin = [[loadedPluginClass alloc] init];
			if(changed == 0)
			{
				id shouldAct;
				if([loadedPlugin respondsToSelector:@selector(shouldBeMuted)])
				{
					shouldAct = [loadedPlugin performSelector:@selector(shouldBeMuted)];
				}else
				{
					shouldAct = [NSNumber numberWithBool:YES];
				}
				
				if([shouldAct boolValue] == YES)
				{
					if([loadedPlugin respondsToSelector:@selector(ringerWillBeMuted)])
					{
						[loadedPlugin performSelector:@selector(ringerWillBeMuted)];
					}
					[loadedPlugin performSelector:@selector(ringerHasBeenMuted)];
				}
			}else
			{
				id shouldAct;
				if([loadedPlugin respondsToSelector:@selector(shouldBeUnmuted)])
				{
					shouldAct = [loadedPlugin performSelector:@selector(shouldBeUnmuted)];
				}else
				{
					shouldAct = [NSNumber numberWithBool:YES];
				}
				
				if([shouldAct boolValue] == YES)
				{
					if([loadedPlugin respondsToSelector:@selector(ringerWillBeUnmuted)])
					{
						[loadedPlugin performSelector:@selector(ringerWillBeUnmuted)];
					}
					[loadedPlugin performSelector:@selector(ringerHasBeenUnmuted)];
				}
			}
		}
	}
	
	[customPlugin release];
}
%end