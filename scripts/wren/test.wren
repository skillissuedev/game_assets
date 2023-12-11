import "engine" for EngineSystem

class SystemBasics {
	static start() {
		var object = EngineSystem.new_empty_object("obj")
		System.print(object)
	}

	static update() {
	}

	static render() {

	}

	static get_call_list() {

	}

	static get_objects_list() {

	}
}

class SystemCalls {
	static say_yo() {
		System.print("yo")
	}
}

