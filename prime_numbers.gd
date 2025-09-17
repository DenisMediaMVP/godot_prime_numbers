extends Node



var limit : int = 10000000

var thread : Thread
var threads : Array[Thread]
var number_of_thread : int = 10

var thread_id

var Mutex_prime_function : Mutex = Mutex.new()

var primes := PackedInt32Array([2])





func primes_up_to(limit: int,new_thread:Thread) -> void:
	var thread_calculation_t0 : float = Time.get_ticks_msec()
	
	if limit < 2:
		return PackedInt32Array()
	var size := (limit - 1) / 2                 # only odds (map 2*i+3)
	var sieve := PackedByteArray()
	sieve.resize(size)
	var root := int(sqrt(limit))
	var i := 0
	while 2*i + 3 <= root:
		if sieve[i] == 0:
			var p := 2*i + 3
			var start := (p*p - 3) >> 1         # index of p*p
			for j in range(start, size, p):
				sieve[j] = 1
		i += 1
	var primes := PackedInt32Array([2])
	for k in range(size):
		if sieve[k] == 0:
			primes.append(2*k + 3)
	
	
	if new_thread:
		var thread_id = new_thread.get_id()
		var thread_calculation_final : float = (Time.get_ticks_msec() - thread_calculation_t0) / 1000
		print(" THREAD ID = " + str(thread_id) + "tiempo de calculado = " + str(thread_calculation_final))
		
	if not new_thread:
		var thread_calculation_final : float = (Time.get_ticks_msec() - thread_calculation_t0) / 1000
		print(" MAIN THREAD  = " + "tiempo de calculado = " + str(thread_calculation_final))
		
func _enter_tree() -> void:
	for thread in threads:
		thread.wait_to_finish()


func _on_start_main_pressed() -> void:
	var total_time : float 
	var t0:float = Time.get_ticks_msec()
	
	for i in 10:
		var new_thread = null
		primes_up_to(limit,new_thread)
	total_time = (Time.get_ticks_msec() - t0) / 1000
		
	print("MAIN THREAD TOTAL TIME = " + str(total_time))


func _on_start_prime_search_pressed() -> void:
	var total_time : float 
	var t0:float = Time.get_ticks_msec()
	
	for i in number_of_thread:
		
		var new_thread = Thread.new()
		threads.append(new_thread)
		new_thread.start(primes_up_to.bind(limit,new_thread))
		
	for thread in threads:
		thread.wait_to_finish()
		
	total_time = (Time.get_ticks_msec() - t0) / 1000
	print("THREAD TOTAL TIME = " + str(total_time))
