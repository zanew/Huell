# Huell

Huell is a library that allows you to set schedules on your Phillips Hue lights
with the day and night cycle.

## Connecting to the Hue bridge

You can connect to the Phillips Hue bridge by calling the Hue API shared
instance and authenticating.

    HueAPI.sharedInstance.configureServiceAndAuthenticate(withBaseIP: self.bridgeIP, deviceType: "Derp").onSuccess {
        response in
        print("response: \(response)")
    }.onFailure {
        error in
        print("error: \(error)")
    }

This returns a request object which you can use to determine whether or not the configuration was successful as demonstrated above. Then listen for updates to schedules that are posted with `listenForSchedulesResource(withService service: Service)`

## Creating schedules

You can create a `Schedule` by hand
`let schedule = Schedule(name: name, description: description, command: Command, localTime: date)`

Or by passing in a `Body` to one of the specialized schedule creation functions.

    let body = Body(on: true, transitionTime: CircadianManager.sunriseAndSetDurationInMilliseconds, brightness: Constants.HueAPI.minBrightness, hue: Constants.HueAPI.warmestHue)
    let schedule = upcomingSunsetSchedule(withDate: Date(), body: body)

Then, you can add it to a list or create a `ScheduleSet`

## Posting schedules

You can post a schedule using the calling

    postSequentialWeeklyCircadianSchedule(_ scheduleSet: DayScheduleSet)
or 

    postCircadianSchedules([schedule1, schedule2, schedule3])
